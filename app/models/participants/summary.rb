module Participants
  class Summary
    def stats
      stats = {}
      Participant::COUNTRIES.each do |country|
        stats[country] = {
          recruited: Participant.rds_participants.where(country:).size,
          eligible: Participant.rds_participants.eligible.where(country:).size,
          ineligible: Participant.rds_participants.ineligible.where(country:).size,
          derived: Participant.rds_participants.derived.where(country:).size,
          excluded: Participant.rds_participants.excluded.where(country:).size,
          contactable: Participant.rds_participants.contactable.where(country:).size,
          accepted: Participant.rds_participants.eligible_completed_main_block.where(country:).size
        }
      end
      stats
    end
  end
end
