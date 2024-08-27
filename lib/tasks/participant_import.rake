desc 'Import participants from CSV file'

task participant_import: :environment do |_t, _args|
  seeds_filename = Rails.root.join('data/vietnam_seeds_portioned.csv')
  puts "Importing seeds from #{seeds_filename}"
  seed_codes = []
  alt_seed_codes = []
  csv_file = CSV.open(seeds_filename)
  csv_file.each do |row|
    puts "#{csv_file.lineno} => #{row}"
    next if row[0].blank?

    csv_file.lineno < 74 ? seed_codes << row[0] : alt_seed_codes << row[0]
  end
  puts "Seed codes = #{seed_codes}"
  puts "Alternate seed codes = #{alt_seed_codes}"

  phone_numbers = Set.new
  filename = Rails.root.join('data/vietnam.csv')
  puts "Importing participants from #{filename}"
  CSV.foreach(filename, headers: true) do |row|
    break if row[0].blank?

    puts "Importing #{row}"
    participant = Participant.find_by(email: row[1])
    phone_number = row[2]
    phone_number = "#{row[2]};#{row[0]}" if phone_numbers.include?(phone_number)
    phone_numbers.add(phone_number)
    # if participant is found, update it, otherwise create a new one
    if participant.nil?
      Participant.create!(country: Participant.parse_country(row[6]),
                          email: row[1],
                          phone_number:,
                          self_generated_id: row[3],
                          verified: Participant.parse_verification(row[5]),
                          code: row[6],
                          preferred_contact_method: Participant.parse_contact_method(row[7]),
                          sgm_group: row[12],
                          seed: seed_codes.include?(row[6]),
                          alternate_seed: alt_seed_codes.include?(row[6]),
                          baseline_participant_id: row[0])
    else
      participant.update!(country: Participant.parse_country(row[6]),
                          email: row[1],
                          phone_number:,
                          self_generated_id: row[3],
                          verified: Participant.parse_verification(row[5]),
                          code: row[6],
                          preferred_contact_method: Participant.parse_contact_method(row[7]),
                          sgm_group: row[12],
                          seed: seed_codes.include?(row[6]),
                          alternate_seed: alt_seed_codes.include?(row[6]),
                          baseline_participant_id: row[0])
    end
  end
end
