require 'sorted_set'

# == Schema Information
#
# Table name: participants
#
#  id                       :bigint           not null, primary key
#  email                    :string
#  phone_number             :string
#  country                  :string
#  self_generated_id        :string
#  rds_id                   :string
#  code                     :string
#  referrer_code            :string
#  sgm_group                :string
#  referrer_sgm_group       :string
#  match                    :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  preferred_contact_method :string
#  verified                 :boolean          default(FALSE)
#  verification_code        :string
#  include                  :boolean          default(TRUE)
#  seed                     :boolean          default(FALSE)
#  remind                   :boolean          default(TRUE)
#  quota_met                :boolean          default(FALSE)
#  baseline_participant_id  :integer
#  agree_to_recruit         :boolean          default(TRUE)
#  wants_payment            :boolean          default(TRUE)
#  opt_out                  :boolean          default(FALSE)
#  due_on                   :datetime
#  derived_seed             :boolean          default(FALSE)
#  chain_level              :integer          default(0)
#  language_code            :string           default("en")
#
class Participant < ApplicationRecord
  has_many :survey_responses, dependent: :destroy, inverse_of: :participant
  has_many :reminders, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true #, phone: true
  validates :country, presence: true

  accepts_nested_attributes_for :survey_responses, allow_destroy: true

  before_save { self.email = email&.downcase&.strip }
  before_save { self.sgm_group = sgm_group&.downcase }
  before_save { self.sgm_group = 'blank' if sgm_group.blank? }
  before_save { self.referrer_sgm_group = referrer_sgm_group&.downcase }
  before_save { self.language_code = language_code&.downcase&.strip }
  before_save :normalize_phone_number
  before_create :assign_identifiers
  before_create :enforce_unique_code
  after_create :non_seed_rds_attributes
  after_save :sgm_group_checks

  scope :excluded, -> { where(include: false) }
  scope :eligible, -> { where(include: true).where(sgm_group: ELIGIBLE_SGM_GROUPS) }
  scope :eligible_completed_main_block, lambda {
    eligible.joins(:survey_responses)
            .where(survey_responses: { survey_title: BASELINE_TITLE })
            .where(survey_responses: { duplicate: false })
            .where('metadata @> hstore(:key, :value)', key: 'main_block', value: 'true')
  }
  scope :ineligible, -> { where(include: true).where(sgm_group: INELIGIBLE_SGM_GROUPS) }
  scope :blanks, -> { where(include: true).where(sgm_group: 'blank') }
  scope :derived, lambda {
    ineligible.joins(:survey_responses)
              .where(survey_responses: { survey_title: BASELINE_TITLE })
              .where(survey_responses: { duplicate: false })
              .where('metadata @> hstore(:key, :value)', key: 'attraction_sgm_group', value: 'eligible')
  }
  scope :contactable, lambda {
    eligible_completed_main_block
      .joins(:survey_responses)
      .where(survey_responses: { survey_title: BASELINE_TITLE })
      .where(survey_responses: { duplicate: false })
      .where('metadata @> hstore(:key, :value)', key: 'can_contact', value: 'true')
  }
  scope :seeds, -> { where(seed: true) }
  scope :rds_participants, -> { where(baseline_participant_id: nil).where(seed: false) }

  def consents
    survey_responses.where(survey_title: 'SMILE Consent - RDS').order(:created_at)
  end

  def seed_consents
    survey_responses.where(survey_title: 'SMILE Consent - RDS Seeds').order(:created_at)
  end

  def contacts
    survey_responses.where(survey_title: 'SMILE Contact Info Form - Baseline RDS').order(:created_at)
  end

  def baselines
    survey_responses.where(survey_title: BASELINE_TITLE).order(:created_at)
  end

  def safety_plans
    survey_responses.where(survey_title: 'Safety Planning').order(:created_at)
  end

  def recruitments
    survey_responses.where(survey_title: 'SMILE Recruitment - RDS').order(:created_at)
  end

  def baseline
    baselines.where(duplicate: false).first
  end

  def consent
    consents.where(duplicate: false).first
  end

  def contact
    contacts.where(duplicate: false).first
  end

  def send_verification_message(language)
    # return if verified
    language = language&.downcase&.strip
    language = 'en' if language.blank?
    language = 'en' if language == 'sw'
    ParticipantVerificationJob.perform_now(id, preferred_contact_method, language)
  end

  def contact_method
    if preferred_contact_method == '1'
      'Email'
    elsif preferred_contact_method == '2'
      'Phone'
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def verify(v_code)
    return if v_code.blank?

    self.verification_code = v_code
    save

    if %w[B K V].include? v_code[0]
      self.verified = true
      save
      'approved'
    else
      to = if preferred_contact_method == '1'
             email
           else
             phone_number
           end
      client = Twilio::REST::Client.new(Rails.application.credentials.config[:TWILIO_SID],
                                        Rails.application.credentials.config[:TWILIO_AUTH])

      begin
        verification_check = client.verify.services(Rails.application.credentials.config[:TWILIO_SERVICE])
                                   .verification_checks.create(to:, code: v_code)
        status = verification_check.status
        if status == 'approved'
          self.verified = true
          save
        end
        status
      rescue Twilio::REST::RestError => e
        Rails.logger.error e.message
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # Include participants who have the following characteristics:
  # i) have include = true
  # ii) the sgm_group is not 'blank', not 'ineligible', and not 'no group'
  # iii) have completed the baseline survey
  def self.eligible_participants
    # Participant.where(include: true).where.not(sgm_group: ineligible_sgm_groups)

    Participant.includes(:survey_responses)
               .where(include: true)
               .where.not(sgm_group: INELIGIBLE_SGM_GROUPS)
               .where(survey_responses: { survey_title: BASELINE_TITLE })
               .where(survey_responses: { survey_complete: true })
  end

  # rubocop:disable Metrics/MethodLength
  def self.weekly_statistics(kountry)
    stats = []
    participants = eligible_participants.where(country: kountry).group_by_week(:created_at, format: '%m/%d/%y', week_start: :monday).count
    total = []
    index = 0
    participants.each do |week, count|
      total << { week => [count] }
      list = total[index][week]
      list << count
      stats << { week => list }
      index += 1
    end
    stats
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.weekly_statistics_by_country
    Groupdate.week_start = :monday
    weeks = SortedSet.new
    stats = {}
    COUNTRIES.each do |country|
      country_stats = {}
      participants = eligible_participants.where(country:).group_by_week(:created_at, format: '%m/%d/%y', week_start: :monday).count
      participants.each do |week, count|
        next unless count.positive?

        country_stats[week] = count
        weeks << Date.strptime(week, '%m/%d/%y')
      end
      stats[country] = country_stats
    end
    [weeks, stats]
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.weekly_participants
    wsbc = weekly_statistics_by_country
    final_stats = {}
    wsbc[1].each do |country, country_stats|
      country_week_list = []
      wsbc[0].each do |week|
        week_str = week.strftime('%m/%d/%y')
        country_week_list << if country_stats[week_str].blank?
                               { week_str => 0 }
                             else
                               { week_str => country_stats[week_str] }
                             end
      end
      final_stats[country] = country_week_list
    end
    final_stats
  end
  # rubocop:enable Metrics/MethodLength

  def to_s
    "#{self_generated_id} #{email}"
  end

  def self.rds_enrollment
    Participants::RdsEnrollment.new.file
  end

  def self.enrollment
    Participants::EnrollmentLogbook.new.file
  end

  def self.participant_level
    Participants::ParticipantLevelData.new.file
  end

  def self.enrolled_eligible_participants
    Participant.includes(:survey_responses)
               .where(include: true)
               .where.not(sgm_group: INELIGIBLE_SGM_GROUPS)
  end

  def ip_addresses
    survey_responses.map { |sr| sr.ip_address&.strip }.uniq.compact_blank
  end

  def duration
    d = baseline&.duration
    len = nil
    len = (d.to_i / 60.0).ceil if d
    len
  end

  def completion
    baseline&.progress
  end

  def age_year_match
    birth_year = contact&.birth_year
    age = baseline&.age
    return 'No' if birth_year.blank? || age.blank?

    cal_age = created_at.year - birth_year.to_i
    diff = cal_age - age.to_i
    diff.abs <= 2 ? 'Yes' : 'No'
  end

  def race
    baseline&.race
  end

  def ethnicity
    baseline&.ethnicity
  end

  def gender
    baseline&.gender
  end

  def age
    baseline&.age
  end

  def gender_identity
    baseline&.gender_identity_label
  end

  def sexual_orientation
    baseline&.sexual_orientation_label
  end

  def intersex
    baseline&.intersex
  end

  def sexual_attraction
    baseline&.sexual_attraction_label
  end

  def attraction_eligibility
    baseline&.attraction_sgm_group
  end

  def mismatch
    mm = baseline&.sgm_group_mismatch?
    mm ? 'Yes' : 'No'
  end

  def age_unit
    'Years'
  end

  def self.assign_sgm_groups
    Participant.find_each(&:assign_sgm_group)
  end

  def assign_sgm_group
    filter_duplicate_baselines
    reload
    return if baseline.nil? || baseline.sgm_group == sgm_group

    self.sgm_group = baseline.sgm_group
    save
  end

  def filter_duplicate_baselines
    return if baselines.empty?

    accepted = baselines.where(survey_complete: true).first
    if accepted
      duplicates = baselines.where.not(id: accepted.id)
      update_non_duplicate(accepted)
      update_duplicates(duplicates)
    else
      filter_duplicate_baselines_by_progress
    end
  end

  def most_progress
    progs = baselines.map { |b| b.progress.to_i }
    max_prog = progs.max
    return nil if max_prog.nil?

    baselines.where('metadata @> hstore(:key, :value)', key: 'progress', value: max_prog.to_s).first
  end

  def filter_duplicate_baselines_by_progress
    accepted = most_progress
    accepted = baselines.first if accepted.nil?
    duplicates = baselines.where.not(id: accepted.id)
    update_non_duplicate(accepted)
    update_duplicates(duplicates)
  end

  def recruiter
    Participant.where(code: referrer_code)&.first if referrer_code.present?
  end

  def recruits
    Participant.where(referrer_code: code)
  end

  def eligible_recruits
    recruits.where(include: true).where(sgm_group: ELIGIBLE_SGM_GROUPS)
  end

  def eligible_completed_recruits
    eligible_recruits.joins(:survey_responses)
                     .where(survey_responses: { survey_title: BASELINE_TITLE })
                     .where(survey_responses: { survey_complete: true })
                     .where(survey_responses: { duplicate: false })
                     .where('metadata @> hstore(:key, :value)', key: 'main_block', value: 'true')
  end

  def level_one
    recruits.pluck(:code)
  end

  def level_two
    recruits = Participant.where(referrer_code: level_one)
    recruits.pluck(:code)
  end

  def level_three
    recruits = Participant.where(referrer_code: level_two)
    recruits.pluck(:code)
  end

  def level_four
    recruits = Participant.where(referrer_code: level_three)
    recruits.pluck(:code)
  end

  def level_five
    recruits = Participant.where(referrer_code: level_four)
    recruits.pluck(:code)
  end

  def reminder_quota_met
    reminders.size >= 3
  end

  def recruitment_quota_met
    eligible_completed_recruits.size >= 2
  end

  def sgm_match
    sgm_group == referrer_sgm_group
  end

  def sgm_group_label(locale = nil)
    locale = language_code if locale.blank?
    locale = 'en' if locale.blank?
    locale = locale&.downcase&.strip
    SGM_GROUPS_PLURAL[locale][sgm_group]
  end

  def self.parse_country(code)
    prefix = code[0].upcase
    countries = { 'B' => 'Brazil', 'K' => 'Kenya', 'V' => 'Vietnam' }
    countries[prefix]
  end

  def self.parse_contact_method(method)
    if method == 'Email'
      '1'
    elsif method == 'Phone'
      '2'
    end
  end

  def self.parse_verification(status)
    if status == 'TRUE'
      true
    elsif status == 'FALSE'
      false
    end
  end

  def start_rds
    return unless seed

    seed_rds_attributes
    schedule_seed_reminders
  end

  # rubocop:disable Metrics/AbcSize
  def schedule_seed_reminders
    if preferred_contact_method == '1' && email.present?
      RdsMailer.with(participant: self).invite_initial.deliver_now
      RdsMailer.with(participant: self).invite_reminder.deliver_later(wait: REMINDERS[:one])
    elsif preferred_contact_method == '2' && phone_number.present?
      RecruitmentReminderJob.perform_now(id, 'seed_initial')
      RecruitmentReminderJob.set(wait: REMINDERS[:one]).perform_later(id, 'seed_reminder')
    end
  end
  # rubocop:enable Metrics/AbcSize

  def seed_rds_attributes
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(rds_id: code, due_on: DateTime.now + 14.days)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def non_seed_rds_attributes
    return if seed

    rds_code = code
    rds_code = "#{recruiter.rds_id}=#{code}" if recruiter
    levels = rds_code.split('=')
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(rds_id: rds_code, chain_level: levels.size - 1)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def set_due_date
    return if due_on

    # rubocop:disable Rails/SkipsModelValidations
    update_columns(due_on: DateTime.now + 14.days)
    # rubocop:enable Rails/SkipsModelValidations
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def seed_post_consent_communication
    if preferred_contact_method == '1'
      RdsMailer.with(participant: self).post_consent.deliver_now
      RdsMailer.with(participant: self).post_consent_reminder.deliver_later(wait: REMINDERS[:one])
      RdsMailer.with(participant: self).payment.deliver_later(wait: REMINDERS[:two])
      RdsMailer.with(participant: self).gratitude.deliver_later(wait: REMINDERS[:two])
    elsif preferred_contact_method == '2'
      RecruitmentReminderJob.perform_now(id, 'seed_post_consent')
      RecruitmentReminderJob.set(wait: REMINDERS[:one]).perform_later(id, 'seed_post_consent_reminder')
      RecruitmentReminderJob.set(wait: REMINDERS[:two]).perform_later(id, 'payment')
      RecruitmentReminderJob.set(wait: REMINDERS[:two]).perform_later(id, 'gratitude')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Style/CaseLikeIf
  def country_contact
    if country == 'Vietnam'
      Rails.application.credentials.config[:VIETNAM_CONTACTS]
    elsif country == 'Kenya'
      Rails.application.credentials.config[:KENYA_CONTACTS]
    elsif country == 'Brazil'
      Rails.application.credentials.config[:BRAZIL_CONTACTS]
    end
  end
  # rubocop:enable Style/CaseLikeIf

  # rubocop:disable Style/CaseLikeIf
  def country_contact2
    if country == 'Vietnam'
      Rails.application.credentials.config[:VIETNAM_CONTACTS2]
    elsif country == 'Kenya'
      Rails.application.credentials.config[:KENYA_CONTACTS]
    elsif country == 'Brazil'
      Rails.application.credentials.config[:BRAZIL_CONTACTS]
    end
  end
  # rubocop:enable Style/CaseLikeIf

  def recruitment_amount
    payments = { 'Vietnam' => '25,000 VND', 'Kenya' => 'KES 200', 'Brazil' => 'R$ 7' }
    payments[country]
  end

  def survey_amount
    payments = { 'Vietnam' => '50,000 VND', 'Kenya' => 'KES 300', 'Brazil' => 'R$ 10' }
    payments[country]
  end

  def payment_amount
    if recruits.size >= 2
      max_amount
    elsif recruits.size == 1
      one_invite_amount
    elsif baseline
      survey_amount
    else
      payments = { 'Vietnam' => '0 VND', 'Kenya' => 'KES 0', 'Brazil' => 'R$ 0' }
      payments[country]
    end
  end

  def max_amount
    payments = { 'Vietnam' => '100,000 VND', 'Kenya' => 'KES 700', 'Brazil' => 'R$ 24' }
    payments = { 'Vietnam' => '50,000 VND', 'Kenya' => 'KES 400', 'Brazil' => 'R$ 14' } if seed
    payments[country]
  end

  def one_invite_amount
    payments = { 'Vietnam' => '75,000 VND', 'Kenya' => 'KES 500', 'Brazil' => 'R$ 17' }
    payments = { 'Vietnam' => '25,000 VND', 'Kenya' => 'KES 200', 'Brazil' => 'R$ 7' } if seed
    payments[country]
  end

  def zero_payment_amount
    ['0 VND', 'KES 0', 'R$ 0']
  end

  def participated?
    zero_payment_amount.exclude?(payment_amount)
  end

  def sgm_group_enrolling
    SGM_GROUP_RECRUITMENT[country][sgm_group]
  end

  def update_recruiter_quota
    return if recruiter.nil?

    # rubocop:disable Rails/SkipsModelValidations
    recruiter.update_column(:quota_met, recruiter.recruitment_quota_met)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def previous_participant
    return true if baseline_participant_id
    return false unless baseline

    baseline.survey_complete
  end

  def recruiter_quota_met?
    return false if recruiter.nil? || recruiter.quota_met == false
    return false if recruiter.quota_met &&
                    recruiter.eligible_completed_recruits.pluck(:id).include?(id)

    true
  end

  def invite_expired?
    return false if due_on.nil?

    due_on < DateTime.now
  end

  def formatted_phone_number
    parsed_phone = Phonelib.parse(phone_number)
    return phone_number if parsed_phone.invalid?

    parsed_phone.full_international
  end

  def locale
    return language_code if language_code.present?

    loc = 'en'
    loc = 'vi' if country == 'Vietnam'
    loc
  end

  # Reminder communication conditions
  def invite_reminder_met?
    return true if seed && agree_to_recruit && remind && seed_consents.empty? &&
                   !opt_out && !invite_expired?

    false
  end

  def url_params
    params = { code:, Q_Language: language_code&.upcase }
    enc = Base64.urlsafe_encode64 params.to_json
    "Q_EED=#{enc}"
  end

  def url_params2
    params = { referrer_code: code, Q_Language: language_code&.upcase }
    enc = Base64.urlsafe_encode64 params.to_json
    "Q_EED=#{enc}"
  end

  def self.ransackable_attributes(auth_object = nil)
    ["agree_to_recruit", "baseline_participant_id", "chain_level", "code", "country", "created_at", "derived_seed", "due_on", "email", "id", "include", "language_code", "match", "opt_out", "phone_number", "preferred_contact_method", "quota_met", "rds_id", "referrer_code", "referrer_sgm_group", "remind", "seed", "self_generated_id", "sgm_group", "updated_at", "verification_code", "verified", "wants_payment"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["reminders", "survey_responses"]
  end

  private

  def update_duplicates(duplicates)
    # rubocop:disable Rails::SkipsModelValidations
    duplicates.update_all(duplicate: true)
    # rubocop:enable Rails::SkipsModelValidations
  end

  def update_non_duplicate(accepted)
    # rubocop:disable Rails::SkipsModelValidations
    accepted.update_column(:duplicate, false)
    # rubocop:enable Rails::SkipsModelValidations
  end

  def assign_identifiers
    self.code = "#{country[0].upcase}-#{Random.rand(10_000_000...99_999_999)}" if code.blank?
  end

  def enforce_unique_code
    begin
      self.code = "#{country[0].upcase}-#{Random.rand(10_000_000...99_999_999)}"
    end while self.class.exists?(code:)
  end

  def sgm_group_checks
    # rubocop:disable Rails::SkipsModelValidations
    update_columns(referrer_sgm_group: check_referrer_sgm_group, match: check_match)
    reload
    update_columns(derived_seed: check_derived_seed)
    # rubocop:enable Rails::SkipsModelValidations
  end

  def check_referrer_sgm_group
    if recruiter.nil?
      nil
    else
      recruiter.sgm_group
    end
  end

  def check_match
    if recruiter.nil? ||
       ELIGIBLE_SGM_GROUPS.exclude?(sgm_group) ||
       ELIGIBLE_SGM_GROUPS.exclude?(referrer_sgm_group)
      false
    else
      sgm_match
    end
  end

  def check_derived_seed
    if seed || match
      false
    else
      SGM_GROUP_RECRUITMENT[country][sgm_group]
    end
  end

  def normalize_phone_number
    return if phone_number.blank?

    self.phone_number = Phonelib.parse(phone_number).full_e164
  end
end
