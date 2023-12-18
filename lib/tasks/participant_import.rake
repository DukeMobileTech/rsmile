desc 'Import participants from CSV file'

task participant_import: :environment do |_t, _args|
  filename = Rails.root.join('data/participants.csv')
  puts "Importing participants from #{filename}"
  CSV.foreach(filename, headers: true) do |row|
    next if row[0].blank?

    puts "Importing #{row[0]} => #{row[1]}"
    Participant.create!(country: Participant.parse_country(row[6]),
                        email: row[0],
                        phone_number: row[1],
                        self_generated_id: row[2],
                        verified: Participant.parse_verification(row[5]),
                        code: row[6],
                        preferred_contact_method: Participant.parse_contact_method(row[7]),
                        sgm_group: row[12],
                        seed: false,
                        baseline_participant_id: row[0])
  end
end
