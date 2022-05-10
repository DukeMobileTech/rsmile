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

  def self.verify(verification_code, email)
    participant = find_by(email: email&.downcase&.strip)
    to = if participant.preferred_contact_method == '1'
           participant.email
         else
           participant.phone_number
         end
    client = Twilio::REST::Client.new(Rails.application.credentials.config[:TWILIO_SID],
                                      Rails.application.credentials.config[:TWILIO_AUTH])

    begin
      verification_check = client.verify.services(Rails.application.credentials.config[:TWILIO_SERVICE])
                                 .verification_checks.create(to: to, code: verification_code)
      status = verification_check.status
      if status == 'approved'
        participant.verified = true
        participant.save
      end
      status
    rescue Twilio::REST::RestError => e
      Rails.logger.error e.message
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

  def self.sgm_stats(kountry)
    stats = {}
    participants = Participant.where(country: kountry)
    all_sgm_groups.each do |group|
      stats[group] = participants.count { |participant| participant.sgm_group == group }
    end
    stats
  end

  def self.weekly_statistics(kountry)
    stats = []
    participants = Participant.where(country: kountry).group_by_week(:created_at, format: '%m/%d/%Y',
                                                                                  week_start: :monday).count
    participants.each do |week, count|
      stats << { week => count }
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

  # def self.existing_user(address, sgi)
  #   sgi = nil if sgi.empty?
  #   participant = find_by(email: address&.downcase&.strip, self_generated_id: sgi)
  #   { id: participant&.id, self_generated_id: participant&.self_generated_id,
  #     country: participant&.country, verified: participant&.verified }
  # end

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
                       participant.sgm_group, participant.ip_addresses.join(' | '),
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
    survey_responses.map { |sr| sr.ip_address }.uniq
  end

  def duration
    d = baselines.last&.duration
    len = nil
    len = (d.to_i / 60.0).ceil if d
    len
  end

  def age_year_match
    birth_year = contacts.last&.birth_year
    return 'No' if birth_year.nil?

    cal_age = created_at.year - birth_year.to_i
    diff = cal_age - baselines.last&.age&.to_i
    diff.abs <= 2 ? 'Yes' : 'No'
  end

  private

  def assign_identifiers
    self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if code.blank?
    self.study_id = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if study_id.blank?
  end
end
