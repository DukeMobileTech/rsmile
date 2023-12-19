module Participants
  class RdsCandidates
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
        participants = Participant.includes(:survey_responses).contactable.where(country: country)
        participants.each do |participant|
          sheet.add_row participant_row(participant)
        end
        add_summary(sheet, participants)
      end
    end

    def country_header
      ['Database ID', 'Email', 'Phone Number', 'Self Generated ID', 'Date of Enrollment',
       'Verified', 'Code', 'Contact Method', 'Gender Identity', 'Sexual Orientation', 'Intersex',
       'Sexual Attraction', 'SGM Group', 'Race', 'Ethnicity', 'Locality', 'City', 'Region',
       'Network', 'Education', 'Age']
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def participant_row(participant)
      [participant.id, participant.email, participant.pretty_phone_number,
       participant.self_generated_id, participant.consent&.created_at&.strftime('%Y-%m-%d'),
       participant.verified, participant.code, participant.contact_method,
       participant.gender_identity, participant.sexual_orientation,
       participant.intersex, participant.sexual_attraction, participant.sgm_group,
       participant.race, participant.ethnicity, participant.baseline&.locality,
       participant.baseline&.city, participant.baseline&.region,
       participant.baseline&.sgm_network_size, participant.baseline&.education, participant.age]
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def add_summary(sheet, participants)
      total = participants.count
      sheet.add_row []
      sheet.add_row ['SGM Group', 'Count', 'Percent']
      Participant::ELIGIBLE_SGM_GROUPS.each do |sgm_group|
        group_count = participants.where(sgm_group: sgm_group).count
        sheet.add_row [sgm_group, group_count, "#{(group_count.to_f / total * 100).round(1)}%"]
      end
      sheet.add_row ['Total', total, '100%']
      count1 = total + 3
      sheet.add_style "A#{count1}:C#{count1}", b: true
      count2 = count1 + Participant::ELIGIBLE_SGM_GROUPS.size + 1
      sheet.add_style "A#{count2}:C#{count2}", b: true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
