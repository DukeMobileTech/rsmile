class ParticipantDuplicatesJob < ApplicationJob
  queue_as :default

  def perform(participant_id)
    participant = Participant.where(id: participant_id).first
    participant&.filter_duplicate_baselines
  end
end
