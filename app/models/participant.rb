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
#
class Participant < ApplicationRecord
  has_many :survey_responses, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  validates :phone_number, :country, presence: true
  accepts_nested_attributes_for :survey_responses, allow_destroy: true
  before_save :assign_identifiers
  before_save { self.email = email&.downcase }

  def send_verification_message
    # return if verified
    ParticipantVerificationJob.perform_now(id, preferred_contact_method)
  end

  def self.verify(verification_code, email)
    participant = find_by(email: email)
    to = if participant.preferred_contact_method == '1'
           participant.email
         else
           participant.phone_number
         end
    client = Twilio::REST::Client.new(Rails.application.credentials.config[:TWILIO_SID],
                                      Rails.application.credentials.config[:TWILIO_AUTH])
    verification_check = client.verify
                               .services(Rails.application.credentials.config[:TWILIO_SERVICE])
                               .verification_checks
                               .create(to: to, code: verification_code)
    status = verification_check.status
    if status == 'approved'
      participant.verified = true
      participant.save
    end
    status
  end

  def self.summary_stats
    stats = {}
    Participant.all.group_by(&:country).each do |country, participants|
      stats[country] = participants.size
    end
    stats
  end

  private

  def assign_identifiers
    self.code = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if code.blank?
    self.study_id = "#{country[0].upcase}-#{Random.rand(10_000...99_999)}" if study_id.blank?
  end
end
