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
  before_save { self.email = email&.downcase&.strip }
  before_save { self.sgm_group = sgm_group&.downcase }
  before_save { self.sgm_group = 'blank' if sgm_group.blank? }
  before_save { self.referrer_sgm_group = referrer_sgm_group&.downcase }
  before_save { self.resume_code = ('A'..'Z').to_a.sample(5).join if resume_code.blank? }

  def consents
    survey_responses.where(survey_title: 'SMILE Consent')
  end

  def contacts
    survey_responses.where(survey_title: 'SMILE Contact Info Form - Baseline')
  end

  def baselines
    survey_responses.where(survey_title: 'SMILE Survey - Baseline')
  end

  def safety_plans
    survey_responses.where(survey_title: 'Safety Planning')
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
    participants = eligible_participants.where(country: kountry).group_by_week(:created_at, format: '%m/%d/%Y', week_start: :monday).count
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

  def self.add_country_sheet(wb, kountry)
    wb.add_worksheet(name: kountry) do |sheet|
      tab_color = colors[countries.index(kountry)]
      sheet.sheet_pr.tab_color = tab_color
      sheet.add_row country_header
      participants = Participant.where(country: kountry)
                                # TODO: Add back later
                                # .where.not(sgm_group: %w[blank ineligible])
      participants.each do |participant|
        sheet.add_row [participant.self_generated_id, participant.id, participant.baselines.pluck(:id).join(' | '),
                       participant.contacts.pluck(:id).join(' | '), participant.consents.pluck(:id).join(' | '),
                       participant.consents.last&.created_at&.strftime('%Y-%m-%d'),
                       participant.baselines.last&.created_at&.strftime('%Y-%m-%d'),
                       participant.gender_identity, participant.sexual_orientation,
                       participant.intersex, participant.sexual_attraction,
                       participant.attraction_eligibility, participant.sgm_group, participant.mismatch,
                       participant.ip_addresses&.join(' | '), participant.duration,
                       participant.completion, participant.verified, participant.age_year_match, '', '']
      end
    end
  end

  def self.colors
    %w[9C6ACB 6DD865 85B2C9 559F93]
  end

  def self.country_header
    ['Participant Self-Gen ID',	'Participant Database ID', 'Baseline Survey IDs',
     'Contact Info Form ID', 'Consent ID',	'Date of Enrollment (Consent)',
     'Baseline Survey Completion Date', 'Gender Identity',
     'Sexual Orientation', 'Intersex', 'Sexual Attraction', 'Attraction Eligibility',
     'SGM Group', 'Mismatch', 'IP Address', 'Duration (min)',
     '% Survey Completed', 'Verified',	'Age/Year Match',	'Study Outcome', 'Notes']
  end

  def self.countries
    %w[Vietnam Kenya Brazil]
  end

  def ip_addresses
    survey_responses.map { |sr| sr.ip_address&.strip }.uniq.reject { |sr| sr.blank? }
  end

  def duration
    d = baselines.last&.duration
    len = nil
    len = (d.to_i / 60.0).ceil if d
    len
  end

  def completion
    baselines.last&.progress
  end

  def age_year_match
    birth_year = contacts.last&.birth_year
    age = baselines.last&.age&.to_i
    return 'No' if birth_year.blank? || age.blank?

    cal_age = created_at.year - birth_year.to_i
    diff = cal_age - age
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

  def self.add_participant_sheet(workbook)
    workbook.add_worksheet(name: 'Participant Level Data') do |sheet|
      sheet.sheet_pr.tab_color = colors[0]
      sheet.add_row participant_header
      participants = Participant.where.not(sgm_group: %w[blank ineligible])
      participants.each do |participant|
        sheet.add_row [participant.race, participant.ethnicity, participant.gender,
                       participant.age, participant.age_unit]
      end
    end
  end

  def self.participant_header
    ['Race',	'Ethnicity', 'Gender', 'Age', 'Age Unit']
  end

  def race
    baselines.map(&:race).compact_blank.uniq.join('|')
  end

  def ethnicity
    baselines.map(&:ethnicity).compact_blank.uniq.join('|')
  end

  def gender
    baselines.map(&:gender).compact_blank.uniq.join('|')
  end

  def age
    baselines.map(&:age).compact_blank.uniq.join('|')
  end

  def gender_identity
    baselines.map(&:gender_identity_label).compact_blank.uniq.join('|')
  end

  def sexual_orientation
    baselines.map(&:sexual_orientation_label).compact_blank.uniq.join('|')
  end

  def intersex
    baselines.map(&:intersex).compact_blank.uniq.join('|')
  end

  def sexual_attraction
    baselines.map(&:sexual_attraction_label).compact_blank.uniq.join('|')
  end

  def attraction_eligibility
    baselines.map(&:attraction_sgm_group).compact_blank.uniq.join('|')
  end

  def mismatch
    mm = baselines.map(&:sgm_group_mismatch?)
    mm.map { |m| m ? 'Yes' : 'No' }.compact.uniq.join('|')
  end

  def age_unit
    'Years'
  end

  private

  def assign_identifiers
    self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if code.blank?
    self.study_id = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if study_id.blank?
  end
end
