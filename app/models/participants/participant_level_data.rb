module Participants
  class ParticipantLevelData
    def file
      tempfile = Tempfile.new("#{Time.zone.now.to_i}.csv")
      CSV.open(tempfile, 'w') do |csv|
        csv << participant_header
        participants = Participant.enrolled_eligible_participants
        participants.each do |participant|
          csv << participant_row(participant)
        end
      end
      tempfile
    end

    private

    def participant_header
      ['Race',	'Ethnicity', 'Gender', 'Age', 'Age Unit']
    end

    def participant_row(participant)
      [participant.race.presence || 'Unknown', participant.ethnicity.presence || 'Unknown',
       participant.gender.presence || 'Unknown', participant.age, participant.age_unit]
    end
  end
end
