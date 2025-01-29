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

  filename = Rails.root.join('data/vietnam.csv')
  puts "Importing participants from #{filename}"
  CSV.foreach(filename, headers: true) do |row|
    break if row[0].blank?

    puts "Importing #{row}"
    phone_number = Phonelib.parse(row[2]).full_e164
    participants = Participant.where(phone_number: phone_number)
    phone_number = "#{phone_number};#{row[0]}" if participants.size > 1
    # if participant is found, update it, otherwise create a new one
    Participant.find_or_create_by(phone_number: phone_number) do |participant|
      participant.email = row[1]
      participant.country = Participant.parse_country(row[6])
      participant.self_generated_id = row[3]
      participant.verified = Participant.parse_verification(row[5])
      participant.code = row[6]
      participant.preferred_contact_method = Participant.parse_contact_method(row[7])
      participant.sgm_group = row[12]
      participant.seed = seed_codes.include?(row[6])
      participant.alternate_seed = alt_seed_codes.include?(row[6])
      participant.baseline_participant_id = row[0]
      participant.can_contact = row[21]
      participant.save!
    end
  end
end
