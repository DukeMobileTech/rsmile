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
        participants = Participant.contactable.where(country: country)
        participants.each do |participant|
          sheet.add_row participant_row(participant)
        end
      end
    end

    def country_header
      ['Database ID', 'Email', 'Phone Number', 'Self Generated ID', 'Date of Enrollment',
       'Verified', 'Code', 'Contact Method', 'Gender Identity', 'Sexual Orientation', 'Intersex',
       'Sexual Attraction', 'SGM Group', 'Race', 'Ethnicity', 'Locality', 'City', 'Region',
       'Network', 'Education']
    end

    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def participant_row(participant)
      [participant.id, participant.email, participant.pretty_phone_number,
       participant.self_generated_id, participant.consent&.created_at&.strftime('%Y-%m-%d'),
       participant.verified, participant.code, participant.contact_method,
       participant.gender_identity, participant.sexual_orientation,
       participant.intersex, participant.sexual_attraction, participant.sgm_group,
       participant.baseline&.race, participant.baseline&.ethnicity,
       participant.baseline&.locality, participant.baseline&.city,
       participant.baseline&.region, participant.baseline&.sgm_network_size,
       participant.baseline&.education]
    end
    # rubocop:enable Metrics/AbcSize Metrics/PerceivedComplexity Metrics/CyclomaticComplexity
  end
end
