class ParticipantWelcomeSmsJob < ApplicationJob
  queue_as :default

  def perform(participant_id)
    participant = Participant.find(participant_id)
    account_sid = Rails.application.credentials.config[:TWILIO_SID]
    auth_token = Rails.application.credentials.config[:TWILIO_AUTH]
    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.messages.create(
      from: Rails.application.credentials.config[:TWILIO_NUMBER],
      to: participant.phone_number,
      body: "Welcome to the SMILE study. You have successfully signed up.
      When asked in the next survey, please use the code: #{participant.code}"
    )
  end
end
