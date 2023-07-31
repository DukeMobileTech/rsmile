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
  has_many :survey_responses, dependent: :destroy
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

  # Include participants who have the following characteristics:
  # i) have include = true
  # ii) the sgm_group is not 'blank', not 'ineligible', and not 'no group'
  # iii) have completed the baseline survey
  def self.eligible_participants
    # Participant.where(include: true).where.not(sgm_group: ineligible_sgm_groups)

    Participant.includes(:survey_responses)
               .where(include: true)
               .where.not(sgm_group: ineligible_sgm_groups)
               .where(survey_responses: { survey_title: 'SMILE Survey - Baseline' })
               .where(survey_responses: { survey_complete: true })
  end

  def self.ineligible_participants
    Participant.where(include: true)
               .where(sgm_group: ineligible_sgm_groups)
  end

  def self.survey_titles
    ['SMILE Contact Info Form - Baseline', 'SMILE Consent', 'SMILE Survey - Baseline',
     'Safety Planning']
  end

  def self.summary_stats
    stats = {}
    surveys = SurveyResponse.all.includes([:participant])
    eligible_participants.group_by(&:country).each do |country, participants|
      country_surveys = surveys.select { |s| s.country == country }
      stats[country] = { participants: participants.size }
      survey_titles.each do |title|
        title_surveys = country_surveys.select { |s| s.survey_title == title }
        if title == 'SMILE Survey - Baseline'
          # For baseline only count eligible and completed surveys
          title_surveys = country_surveys.select { |s| s.survey_title == title && s.eligible && s.survey_complete }
        end
        nils = title_surveys.select { |ts| ts.participant_id.nil? } # Surveys not attached to participants
        part_ids = title_surveys.pluck(:participant_id).uniq # Remove duplicates
        survey_count = if nils.size > 0
                         (part_ids.size - 1) + nils.size # Count surveys without participants as unique
                       else
                         part_ids.size
                       end
        country_stats = stats[country]
        country_stats[title] = survey_count
        stats[country] = country_stats
      end
    end
    stats
  end

  def self.all_sgm_groups
    ['non-binary person', 'transgender woman', 'transgender man', 'woman attracted to women',
     'man attracted to men', 'multi-attracted woman', 'multi-attracted man', 'no group', 'ineligible', 'blank']
  end

  def self.eligible_sgm_groups
    ['woman attracted to women', 'man attracted to men', 'multi-attracted woman',
     'multi-attracted man', 'non-binary person', 'transgender woman', 'transgender man']
  end

  def self.ineligible_sgm_groups
    ['blank', 'ineligible', 'no group']
  end

  def self.eligible_sgm_stats(kountry)
    stats = {}
    participants = eligible_participants.where(country: kountry)
    eligible_sgm_groups.each do |group|
      stats[group] = participants.count { |participant| participant.sgm_group == group }
    end
    stats
  end

  def self.ineligible_sgm_stats(kountry)
    stats = {}
    participants = ineligible_participants.where(country: kountry)
    ineligible_sgm_groups.each do |group|
      stats[group] = participants.count { |participant| participant.sgm_group == group }
    end
    stats
  end

  def self.blank_stats(kountry)
    no_baseline = []
    baseline_started = []
    participants = Participant.where(include: true)
                              .where(country: kountry)
                              .where(sgm_group: 'blank')
    participants.each do |part|
      if !part.contacts.empty? & part.baselines.empty?
        no_baseline << part
      elsif !part.baselines.empty?
        baseline_started << part
      end
    end
    { 'Contact Info completed but Baseline not started': no_baseline.size,
      'Baseline started but SOGI not completed': baseline_started.size }
  end

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

  def self.weekly_statistics_by_country
    Groupdate.week_start = :monday
    weeks = SortedSet.new
    stats = {}
    countries.each do |country|
      country_stats = {}
      participants = eligible_participants.where(country: country).group_by_week(:created_at, format: '%m/%d/%y', week_start: :monday).count
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

  def self.enrollment
    file = Tempfile.new(Time.now.to_i.to_s)
    Axlsx::Package.new do |p|
      wb = p.workbook
      countries.each do |state|
        add_country_sheet(wb, state)
      end
      p.serialize(file.path)
    end
    file
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

  def self.participant_level
    file = Tempfile.new(Time.zone.now.to_i.to_s)
    Axlsx::Package.new do |p|
      wb = p.workbook
      add_participant_sheet(wb)
      p.serialize(file.path)
    end
    file
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
    baseline = baselines.where(duplicate: false).first
    return if baseline.nil? || baseline.sgm_group == sgm_group

    self.sgm_group = baseline.sgm_group
    save
  end

  def filter_duplicate_baselines
    accepted = baselines.where(duplicate: false)
    return if accepted.size <= 1

    accepted = baselines.where(survey_complete: true).first
    if accepted
      duplicates = baselines.where.not(id: accepted.id)
      accepted.update(duplicate: false)
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
    return unless accepted

    duplicates = baselines.where.not(id: accepted.id)
    accepted.update(duplicate: false)
    update_duplicates(duplicates)
  end

  def update_duplicates(duplicates)
    duplicates.each do |duplicate|
      duplicate.update(duplicate: true)
    end
  end

  # an unnamed instance of the Participant class
  class << self

    # private class methods
    private

    def colors
      %w[9C6ACB 6DD865 85B2C9 559F93]
    end

    def countries
      %w[Vietnam Kenya Brazil]
    end

    def country_header
      ['Self Generated ID',	'Database ID', 'Baseline Survey ID',
       'Contact Info Form ID', 'Consent ID',	'Date of Enrollment (Consent)',
       'Baseline Survey Completion Date', 'Gender Identity',
       'Sexual Orientation', 'Intersex', 'Sexual Attraction', 'Attraction Eligibility',
       'SGM Group', 'Mismatch', 'IP Addresses', 'Duration (min)',
       '% Survey Completed', 'Verified',	'Age/Year Match',	'Study Outcome', 'Notes']
    end

    def enrolled_eligible_participants
      Participant.where(include: true)
                 .where.not(sgm_group: ineligible_sgm_groups)
    end

    def add_country_sheet(workbook, kountry)
      workbook.add_worksheet(name: kountry) do |sheet|
        tab_color = colors[countries.index(kountry)]
        sheet.sheet_pr.tab_color = tab_color
        sheet.add_row country_header
        participants = enrolled_eligible_participants.where(country: kountry)
        add_participants_to_sheet(participants, sheet)
        summarize_sgm_groups(participants, sheet)
      end
    end

    def add_participants_to_sheet(participants, sheet)
      participants.each do |participant|
        sheet.add_row [participant.self_generated_id, participant.id, participant.baseline&.id,
                       participant.contact&.id, participant.consent&.id,
                       participant.consent&.created_at&.strftime('%Y-%m-%d'),
                       participant.baseline&.created_at&.strftime('%Y-%m-%d'),
                       participant.gender_identity, participant.sexual_orientation,
                       participant.intersex, participant.sexual_attraction,
                       participant.attraction_eligibility, participant.sgm_group, participant.mismatch,
                       participant.ip_addresses&.join(' | '), participant.duration,
                       participant.completion, participant.verified, participant.age_year_match, '', '']
      end
    end

    def summarize_sgm_groups(participants, sheet)
      sheet.add_row []
      sheet.add_row ['SGM Group', 'Enrollment Count']
      eligible_sgm_groups.each do |group|
        sheet.add_row [group, participants.count { |participant| participant.sgm_group == group }]
      end
      sheet.add_row ['TOTAL', participants.size]
    end

    def add_participant_sheet(workbook)
      workbook.add_worksheet(name: 'Participant Level Data') do |sheet|
        sheet.sheet_pr.tab_color = colors[0]
        sheet.add_row participant_header
        participants = enrolled_eligible_participants
        participants.each do |participant|
          sheet.add_row [participant.race, participant.ethnicity, participant.gender,
                         participant.age, participant.age_unit]
        end
      end
    end

    def participant_header
      ['Race',	'Ethnicity', 'Gender', 'Age', 'Age Unit']
    end
  end

  private

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
