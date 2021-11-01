class ParticipantWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(participant_id)
    participant = Participant.find(participant_id)
    ParticipantMailer.with(participant: participant).welcome_email.deliver_now
  end
end
