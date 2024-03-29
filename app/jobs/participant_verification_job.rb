class ParticipantVerificationJob < ApplicationJob
  queue_as :default

  def perform(participant_id, channel, locale)
    participant = Participant.find(participant_id)
    if channel == '1'
      to = participant.email
      channel = 'email'
    else
      to = participant.phone_number.strip
      channel = 'sms'
    end
    account_sid = Rails.application.credentials.config[:TWILIO_SID]
    auth_token = Rails.application.credentials.config[:TWILIO_AUTH]
    client = Twilio::REST::Client.new(account_sid, auth_token)
    begin
      client.verify.services(Rails.application.credentials.config[:TWILIO_SERVICE])
            .verifications.create(to: to, channel: channel, locale: locale)
    rescue Twilio::REST::RestError => e
      Rails.logger.error e.message
    end
  end
end
