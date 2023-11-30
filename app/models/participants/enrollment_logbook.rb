module Participants
  class EnrollmentLogbook
    def file
      tempfile = Tempfile.new(Time.now.to_i.to_s)
      Axlsx::Package.new do |p|
        wb = p.workbook
        Participant::COUNTRIES.each do |state|
          add_country_sheet(wb, state)
        end
        p.serialize(tempfile.path)
      end
      tempfile
    end

    private

    def add_country_sheet(workbook, country)
      workbook.add_worksheet(name: country) do |sheet|
        tab_color = Participant::COLORS[Participant::COUNTRIES.index(country)]
        sheet.sheet_pr.tab_color = tab_color
        sheet.add_row country_header
        participants = Participant.enrolled_eligible_participants.where(country: country)
        participants.each do |participant|
          sheet.add_row participant_row(participant)
        end
        summarize(participants, sheet, country)
      end
    end

    def country_header
      ['Self Generated ID',	'Database ID', 'Baseline Survey ID',
       'Contact Info Form ID', 'Consent ID',	'Date of Enrollment (Consent)',
       'Baseline Survey Completion Date', 'Gender Identity', 'Sexual Orientation',
       'Intersex', 'SGM Group', 'Duration (min)', '% Survey Completed', 'Verified',
       'Race', 'Ethnicity', 'Study Outcome', 'Notes']
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def participant_row(participant)
      [participant.self_generated_id, participant.id, participant.baseline&.id,
       participant.contact&.id, participant.consent&.id,
       participant.consent&.created_at&.strftime('%Y-%m-%d'),
       participant.baseline&.created_at&.strftime('%Y-%m-%d'),
       participant.gender_identity, participant.sexual_orientation,
       participant.intersex, participant.sgm_group, participant.duration,
       participant.completion, participant.verified, participant.race,
       participant.ethnicity, '', '']
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    def summarize(participants, sheet, country)
      sgm_groups(participants, sheet)
      races(participants, sheet)
      ethnicities(participants, sheet, country)
    end

    def sgm_groups(participants, sheet)
      sheet.add_row []
      sheet.add_row ['SGM Group', 'Enrollment Count']
      Participant::ELIGIBLE_SGM_GROUPS.each do |group|
        sheet.add_row [group, participants.count { |participant| participant.sgm_group == group }]
      end
      sheet.add_row ['TOTAL', participants.size]
    end

    def group_count(participants, race)
      if race == 'Unknown'
        participants.count { |participant| unknown(participant) }
      else
        participants.count { |participant| participant.baseline&.race == race }
      end
    end

    def unknown(participant)
      participant.baseline.nil? || participant.baseline.race == 'Unknown' || participant.baseline.race.blank?
    end

    def races(participants, sheet)
      sheet.add_row []
      sheet.add_row ['Race', 'Enrollment Count']
      ['American Indian', 'Asian', 'Black', 'More than one race', 'Unknown', 'White'].each do |race|
        sheet.add_row [race, group_count(participants, race)]
      end
      sheet.add_row ['TOTAL', participants.size]
    end

    def ethnicities(participants, sheet, country)
      sheet.add_row []
      sheet.add_row ['Ethnicity', 'Enrollment Count']
      if country == 'Brazil'
        sheet.add_row ['Hispanic or Latino', participants.size]
        sheet.add_row ['Not Hispanic or Latino', 0]
      else
        sheet.add_row ['Hispanic or Latino', 0]
        sheet.add_row ['Not Hispanic or Latino', participants.size]
      end
      sheet.add_row ['TOTAL', participants.size]
    end
  end
end
