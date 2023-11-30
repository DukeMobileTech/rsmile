module Participants
  class ParticipantLevelData
    def file
      tempfile = Tempfile.new(Time.zone.now.to_i.to_s)
      Axlsx::Package.new do |p|
        wb = p.workbook
        add_participant_sheet(wb)
        p.serialize(tempfile.path)
      end
      tempfile
    end

    private

    def add_participant_sheet(workbook)
      workbook.add_worksheet(name: 'Participant Level Data') do |sheet|
        sheet.sheet_pr.tab_color = Participant::COLORS[0]
        sheet.add_row participant_header
        participants = Participant.enrolled_eligible_participants
        participants.each do |participant|
          sheet.add_row [participant.race || 'Unknown', participant.ethnicity || 'Unknown',
                         participant.gender || 'Unknown', participant.age || 'Unknown',
                         participant.age_unit]
        end
      end
    end

    def participant_header
      ['Race',	'Ethnicity', 'Gender', 'Age', 'Age Unit']
    end
  end
end
