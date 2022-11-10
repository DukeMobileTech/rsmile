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
#  match                    :boolean
#  raffles_count            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  preferred_contact_method :string
#  verified                 :boolean          default(FALSE)
#  verification_code        :string
#  name                     :string
#  seed                     :boolean          default(FALSE)
#  remind                   :boolean          default(TRUE)
#  enter_raffle             :boolean          default(TRUE)
#  raffle_quota_met         :boolean          default(FALSE)
#
class Participant < ApplicationRecord
  has_many :survey_responses, dependent: :destroy
  has_many :raffles, dependent: :destroy
  has_many :reminders, dependent: :destroy

  before_save { self.code = Random.rand(10_000...99_999) if code.blank? }
  before_save { self.email = email&.downcase&.strip }
  before_save { self.sgm_group = sgm_group&.downcase }
  before_save { self.sgm_group = 'blank' if sgm_group.blank? }
  before_save { self.referrer_sgm_group = referrer_sgm_group&.downcase }
  after_save :check_referrer_sgm_group
  after_save :check_match
  after_save :secondary_seeds

  def first_name
    return 'Participant' if name.blank?

    name.strip.split(' ').first
  end

  def reminder_quota_met
    reminders.size >= 3
  end

  def pilots
    survey_responses.where(survey_title: 'SGM Pilot')
  end

  def recruiter
    Participant.where(code: referrer_code)&.first unless referrer_code.blank?
  end

  def recruits
    Participant.where(referrer_code: code)
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

  def self.summary_stats
    stats = {}
    surveys = SurveyResponse.all.includes([:participant])
    survey_titles = ['SMILE Contact Info Form - Baseline', 'SMILE Consent', 'SMILE Survey - Baseline',
                     'Safety Planning']
    Participant.all.group_by(&:country).each do |country, participants|
      country_surveys = surveys.select { |s| s.country == country }
      stats[country] = { 'participants': participants.size }
      survey_titles.each do |title|
        title_surveys = country_surveys.select { |s| s.survey_title == title }
        country_stats = stats[country]
        country_stats[title] = title_surveys.size
        stats[country] = country_stats
      end
    end
    stats
  end

  def self.all_sgm_groups
    ['non-binary person', 'transgender woman', 'transgender man', 'woman attracted to women',
     'man attracted to men', 'multi-attracted woman', 'multi-attracted man', 'no group', 'ineligible', 'blank']
  end

  def self.pilot_sgm_groups
    ['transgender woman', 'transgender man', 'woman attracted to women', 'neligible', 'blank']
  end

  def self.eligible_sgm_groups
    ['transgender woman', 'transgender man', 'woman attracted to women']
  end

  def self.sgm_stats(kountry)
    stats = {}
    participants = Participant.where(country: kountry)
    all_sgm_groups.each do |group|
      stats[group] = participants.count { |participant| participant.sgm_group == group }
    end
    stats
  end

  def self.blank_stats(kountry)
    no_baseline = []
    baseline_started = []
    participants = Participant.where(country: kountry).where(sgm_group: 'blank')
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
    participants = Participant.where(country: kountry).group_by_week(:created_at, format: '%m/%d/%Y',
                                                                                  week_start: :monday).count
    eligible = Participant.where(country: kountry).where.not(sgm_group: 'ineligible').where.not(sgm_group: 'blank').group_by_week(
      :created_at, format: '%m/%d/%Y', week_start: :monday
    ).count
    total = []
    participants.each do |week, count|
      total << { week => [count] }
    end
    index = 0
    eligible.each do |week, count|
      list = total[index][week]
      list << count
      stats << { week => list }
      index += 1
    end
    stats
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
      participants.each do |participant|
        sheet.add_row [participant.self_generated_id, participant.id, participant.baselines.pluck(:id).join(' | '),
                       participant.contacts.pluck(:id).join(' | '), participant.consents.pluck(:id).join(' | '),
                       participant.consents.last&.created_at&.strftime('%Y-%m-%d'),
                       participant.baselines.last&.created_at&.strftime('%Y-%m-%d'),
                       participant.sgm_group, participant.ip_addresses&.join(' | '),
                       participant.duration, '', participant.verified, participant.age_year_match, '', '']
      end
    end
  end

  def self.colors
    %w[9C6ACB 6DD865 85B2C9 559F93]
  end

  def self.country_header
    ['Participant Self-Gen ID',	'Participant Database ID', 'Baseline Survey IDs',
     'Contact Info Form ID', 'Consent ID',	'Date of Enrollment (Consent)',
     'Baseline Survey Completion Date', 'SGM Group Assigned', 'IP Address',
     'Duration (min)', '% Survey Completed', 'Verified',	'Age/Year Match',	'Study Outcome',
     'Notes']
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

  def age_year_match
    birth_year = contacts.last&.birth_year
    age = baselines.last&.age&.to_i
    return 'No' if birth_year.blank? || age.blank?

    cal_age = created_at.year - birth_year.to_i
    diff = cal_age - age
    diff.abs <= 2 ? 'Yes' : 'No'
  end

  private

  def check_referrer_sgm_group
    return unless recruiter
    return if recruiter.sgm_group == referrer_sgm_group

    self.referrer_sgm_group = recruiter.sgm_group
    save
  end

  def check_match
    return unless recruiter
    return unless Participant.eligible_sgm_groups.include?(recruiter.sgm_group)
    return unless Participant.eligible_sgm_groups.include?(sgm_group)
    return unless Participant.eligible_sgm_groups.include?(referrer_sgm_group)
    return if match && sgm_group == referrer_sgm_group
    return if !match && sgm_group != referrer_sgm_group

    self.match = sgm_group == referrer_sgm_group
    save
  end

  def secondary_seeds
    return if seed
    return if referrer_code.blank?
    return if recruiter.nil?
    return if match
    return unless Participant.eligible_sgm_groups.include?(sgm_group)

    self.seed = true
    save
  end
end
