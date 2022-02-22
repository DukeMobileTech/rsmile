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
  before_save { self.sgm_group = 'no group' if sgm_group.blank? }
  before_save { self.referrer_sgm_group = referrer_sgm_group&.downcase }
  before_create { self.resume_code = ('A'..'Z').to_a.sample(5).join }

  def send_verification_message
    # return if verified
    ParticipantVerificationJob.perform_now(id, preferred_contact_method)
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
      stats[country] = { 'participants': participants.size, 'surveys': country_surveys.size }
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
     'man attracted to men', 'multi-attracted woman', 'multi-attracted man', 'no group', 'ineligible']
  end

  def self.sgm_stats(kountry)
    stats = {}
    participants = Participant.where(country: kountry)
    all_sgm_groups.each do |group|
      stats[group] = participants.count { |participant| participant.sgm_group == group }
    end
    stats
  end

  def self.date_stats(kountry)
    stats = []
    participants = Participant.where(country: kountry).order(:created_at)
    grouped_parts = participants.group_by { |p| p.created_at.to_date.strftime('%m/%d/%Y') }
    dates = (participants.first.created_at.to_date..participants.last.created_at.to_date).to_a
    dates.each do |date|
      f_date = date.strftime('%m/%d/%Y')
      num_parts = grouped_parts[f_date]
      stats << { f_date => num_parts.nil? ? 0 : num_parts.size }
    end
    stats
  end

  def self.check_resume_code(code)
    return { id: nil, self_generated_id: nil, country: nil, status: 'invalid' } if code.blank?

    participant = find_by(resume_code: code&.upcase&.strip)
    if participant
      { id: participant.id, self_generated_id: participant.self_generated_id,
        country: participant.country, status: 'valid' }
    else
      { id: nil, self_generated_id: nil, country: nil, status: 'invalid' }
    end
  end

  private

  def assign_identifiers
    self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if code.blank?
    self.study_id = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if study_id.blank?
  end
end
