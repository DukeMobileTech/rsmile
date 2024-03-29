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
#  study_id                 :string
#  rds_id                   :string
#  code                     :string
#  referrer_code            :string
#  sgm_group                :string
#  referrer_sgm_group       :string
#  match                    :boolean
#  quota                    :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  preferred_contact_method :string
#  verified                 :boolean          default(FALSE)
#  resume_code              :string
#  verification_code        :string
#  include                  :boolean          default(TRUE)
#
class Participant < ApplicationRecord
  has_many :survey_responses, dependent: :destroy, inverse_of: :participant

  validates :email, presence: true, uniqueness: true
  validates :phone_number, :country, presence: true

  accepts_nested_attributes_for :survey_responses, allow_destroy: true

  before_save :assign_identifiers
  before_save :enforce_unique_code
  before_save { self.email = email&.downcase&.strip }
  before_save { self.sgm_group = sgm_group&.downcase }
  before_save { self.sgm_group = 'blank' if sgm_group.blank? }
  before_save { self.referrer_sgm_group = referrer_sgm_group&.downcase }
  before_save { self.resume_code = ('A'..'Z').to_a.sample(5).join if resume_code.blank? }

  scope :excluded, -> { where(include: false) }
  scope :eligible, -> { where(include: true).where(sgm_group: ELIGIBLE_SGM_GROUPS) }
  scope :eligible_completed_main_block, lambda {
    eligible.joins(:survey_responses)
            .where(survey_responses: { survey_title: 'SMILE Survey - Baseline' })
            .where(survey_responses: { duplicate: false })
            .where('metadata @> hstore(:key, :value)', key: 'main_block', value: 'true')
  }
  scope :ineligible, -> { where(include: true).where(sgm_group: INELIGIBLE_SGM_GROUPS) }
  scope :blanks, -> { where(include: true).where(sgm_group: 'blank') }
  scope :derived, lambda {
    ineligible.joins(:survey_responses)
              .where(survey_responses: { survey_title: 'SMILE Survey - Baseline' })
              .where(survey_responses: { duplicate: false })
              .where('metadata @> hstore(:key, :value)', key: 'attraction_sgm_group', value: 'eligible')
  }
  scope :contactable, lambda {
    eligible_completed_main_block
      .joins(:survey_responses)
      .where(survey_responses: { survey_title: 'SMILE Survey - Baseline' })
      .where(survey_responses: { duplicate: false })
      .where('metadata @> hstore(:key, :value)', key: 'can_contact', value: 'true')
  }
  scope :enrolled_eligible_participants, lambda {
    eligible.includes(:survey_responses)
  }

  def accepted?
    return false if include == false ||
                    INELIGIBLE_SGM_GROUPS.include?(sgm_group) ||
                    baseline.nil?

    baseline.main_block == 'true'
  end

  def mobilizer
    baseline&.mobilizer_code
  end

  def source
    baseline&.source_label
  end

  def consents
    survey_responses.where(survey_title: 'SMILE Consent').order(:created_at)
  end

  def contacts
    survey_responses.where(survey_title: 'SMILE Contact Info Form - Baseline').order(:created_at)
  end

  def baselines
    survey_responses.where(survey_title: 'SMILE Survey - Baseline').order(:created_at)
  end

  def safety_plans
    survey_responses.where(survey_title: 'Safety Planning').order(:created_at)
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

  def pretty_phone_number
    number = phone_number&.gsub(/\s+/, '')
    number = "+#{number}" if number[0] != '+'
    number = "#{number[0..2]} #{number[3..]}" if country == 'Brazil' || country == 'Vietnam'
    number = "#{number[0..3]} #{number[4..]}" if country == 'Kenya'
    number
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
                                   .verification_checks.create(to: to, code: v_code)
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

  def self.weekly_statistics(kountry)
    stats = []
    participants = eligible_completed_main_block.where(country: kountry).group_by_week(:created_at, format: '%m/%d/%y', week_start: :monday).count
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

  def self.weekly_statistics_by_country
    Groupdate.week_start = :monday
    weeks = SortedSet.new
    stats = {}
    COUNTRIES.each do |country|
      country_stats = {}
      participants = eligible_completed_main_block.where(country: country).group_by_week(:created_at, format: '%m/%d/%y', week_start: :monday).count
      participants.each do |week, count|
        next unless count.positive?

        country_stats[week] = count
        weeks << Date.strptime(week, '%m/%d/%y')
      end
      stats[country] = country_stats
    end
    [weeks, stats]
  end

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

  def self.check_resume_code(code)
    return { id: nil, self_generated_id: nil, country: nil, status: 'invalid', response_id: nil } if code.blank?

    participant = find_by(resume_code: code&.upcase&.strip)
    if participant
      baseline = participant.survey_responses.where(survey_title: 'SMILE Survey - Baseline',
                                                    survey_complete: false).first
      { id: participant.id, self_generated_id: participant.self_generated_id,
        country: participant.country, status: 'valid', response_id: baseline&.response_uuid }
    else
      { id: nil, self_generated_id: nil, country: nil, status: 'invalid', response_id: nil }
    end
  end

  def to_s
    "#{self_generated_id} #{email}"
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
    baseline&.ethnicity_label
  end

  def gender
    gen = baseline&.gender
    if gen.blank?
      gil = baseline&.gender_identity_label
      gen = identity_label(gil)
    end
    gender_label(gen)
  end

  def identity_label(gil)
    if ['Agender', 'Non-binary Person', 'Questioning Person', 'Another Gender'].include? gil
      'Unknown'
    elsif gil == 'Transgender Woman'
      'Woman'
    elsif gil == 'Transgender Man'
      'Man'
    else
      gil
    end
  end

  def gender_label(gen)
    if gen == 'Woman'
      'Female'
    elsif gen == 'Man'
      'Male'
    else
      gen
    end
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
    age.blank? ? 'Unknown' : 'Years'
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
    self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if code.blank?
    self.study_id = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if study_id.blank?
  end

  def enforce_unique_code
    begin
      self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}"
    end while self.class.exists?(code: code)
  end
end
