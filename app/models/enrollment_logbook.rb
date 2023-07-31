class EnrollmentLogbook
  def file
    tempfile = Tempfile.new(Time.now.to_i.to_s)
    Axlsx::Package.new do |p|
      wb = p.workbook
      Participant.countries.each do |state|
        add_country_sheet(wb, state)
      end
      p.serialize(tempfile.path)
    end
    tempfile
  end

  private

  def add_country_sheet(workbook, country)
    workbook.add_worksheet(name: country) do |sheet|
      tab_color = Participant.colors[Participant.countries.index(country)]
      sheet.sheet_pr.tab_color = tab_color
      sheet.add_row country_header
      participants = Participant.enrolled_eligible_participants.where(country: country)
      participants.each do |participant|
        sheet.add_row participant_row(participant)
      end
      summarize_sgm_groups(participants, sheet)
    end
  end

  def country_header
    ['Self Generated ID',	'Database ID', 'Baseline Survey ID',
     'Contact Info Form ID', 'Consent ID',	'Date of Enrollment (Consent)',
     'Baseline Survey Completion Date', 'Gender Identity',
     'Sexual Orientation', 'Intersex', 'Sexual Attraction', 'Attraction Eligibility',
     'SGM Group', 'Mismatch', 'IP Addresses', 'Duration (min)',
     '% Survey Completed', 'Verified',	'Age/Year Match',	'Study Outcome', 'Notes']
  end

  def participant_row(participant)
    [participant.self_generated_id, participant.id, participant.baseline&.id,
     participant.contact&.id, participant.consent&.id,
     participant.consent&.created_at&.strftime('%Y-%m-%d'),
     participant.baseline&.created_at&.strftime('%Y-%m-%d'),
     participant.gender_identity, participant.sexual_orientation,
     participant.intersex, participant.sexual_attraction,
     participant.attraction_eligibility, participant.sgm_group, participant.mismatch,
     participant.ip_addresses&.join(' | '), participant.duration,
     participant.completion, participant.verified, participant.age_year_match,
     '', '']
  end

  def summarize_sgm_groups(participants, sheet)
    sheet.add_row []
    sheet.add_row ['SGM Group', 'Enrollment Count']
    Participant.eligible_sgm_groups.each do |group|
      sheet.add_row [group, participants.count { |participant| participant.sgm_group == group }]
    end
    sheet.add_row ['TOTAL', participants.size]
  end
end
