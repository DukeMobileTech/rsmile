class ParticipantVerificationJob < ApplicationJob
  queue_as :default

  def perform(participant_id, channel)
    participant = Participant.find(participant_id)
    if channel == "1"
      to = participant.email
      channel = "email"
    else
      to = participant.phone_number
      channel = "sms"
    end
    account_sid = Rails.application.credentials.config[:TWILIO_SID]
    auth_token = Rails.application.credentials.config[:TWILIO_AUTH]
    client = Twilio::REST::Client.new(account_sid, auth_token)
    verification = client.verify
                      .services(Rails.application.credentials.config[:TWILIO_SERVICE])
                      .verifications
                      .create(to: to, channel: channel)
  end
end
