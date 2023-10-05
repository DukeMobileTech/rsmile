module Participants
  class Summary
    def stats
      stats = {}
      Participant::COUNTRIES.each do |country|
        stats[country] = {
          recruited: Participant.where(country: country).size,
          eligible: Participant.eligible.where(country: country).size,
          ineligible: Participant.ineligible.where(country: country).size,
          derived: Participant.derived.where(country: country).size,
          excluded: Participant.excluded.where(country: country).size,
          contactable: Participant.contactable.where(country: country).size,
          accepted: Participant.eligible_completed_main_block.where(country: country).size
        }
      end
      stats
    end
  end
end
