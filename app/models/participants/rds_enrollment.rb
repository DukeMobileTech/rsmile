module Participants
  class RdsEnrollment
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

    def add_country_sheet(workbook, kountry)
      workbook.add_worksheet(name: kountry) do |sheet|
        tab_color = Participant::COLORS[Participant::COUNTRIES.index(kountry)]
        sheet.sheet_pr.tab_color = tab_color
        sheet.add_row country_header
        seeds = Participant.seeds.where(country: kountry)
        participants = Participant.rds_participants.where(country: kountry)
        participants = seeds + participants
        participants.each do |participant|
          sheet.add_row participant_row(participant)
        end
        summarize_sgm_groups(participants, sheet)
      end
    end

    def country_header
      ['Self Generated ID', 'Database ID', 'Email', 'Phone Number', 'Contact Method',
       'SGM Group', 'Referrer SGM Group', 'Match', 'Quota Met', 'Seed', 'Derived Seed',
       'Code', 'Referrer Code', 'Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5',
       'Payment Amount']
    end

    def participant_row(participant)
      [participant.self_generated_id, participant.id, participant.email,
       participant.phone_number, participant.contact_method, participant.sgm_group,
       participant.referrer_sgm_group, participant.match, participant.recruitment_quota_met,
       participant.seed, participant.derived_seed, participant.code, participant.referrer_code,
       participant.level_one.join(', '), participant.level_two.join(', '),
       participant.level_three.join(', '), participant.level_four.join(', '),
       participant.level_five.join(', '), participant.payment_amount]
    end

    def summarize_sgm_groups(participants, sheet)
      sheet.add_row []
      sheet.add_row ['SGM Group', 'Enrollment Count']
      Participant::ELIGIBLE_SGM_GROUPS.each do |group|
        sheet.add_row [group, participants.count { |participant| participant.sgm_group == group }]
      end
      sheet.add_row ['TOTAL', participants.size]
    end
  end
end
