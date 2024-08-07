desc 'Select seeds from participants csv file'

task seed_selector: :environment do |_t, _args|
  filename = Rails.root.join('data/vietnam.csv') # change based on country
  participants = []
  seeds = []
  alt_seeds = []
  CSV.foreach(filename, headers: true) do |row|
    next if row[0].blank?
    next if row[6].blank?

    participant = { code: row[6],
                    sgm_group: row[12],
                    region: row[16] == 'None of the above' ? row[17] : row[16],
                    network_size: row[18].blank? ? -1 : row[18].to_i,
                    locality: row[15] }
    participants << participant
    print "participant: #{participant}\n"
  end
  sgm_groups = participants.pluck(:sgm_group).uniq
  puts "all sgm_groups: #{sgm_groups}"
  regions = participants.pluck(:region).uniq
  puts "all regions: #{regions}"
  sgm_groups.each do |sgm_group|
    group_seeds = []
    alt_group_seeds = []
    # represented_regions = []
    group_participants = participants.select { |p| p[:sgm_group] == sgm_group }
    group_participants = group_participants.sort_by { |p| p[:network_size] }.reverse
    region_list = group_participants.pluck(:region)
    sample_regions = region_list.sample(10)
    puts "sample regions: #{sample_regions}"
    seed_regions = sample_regions.each_with_object(Hash.new(0)) { |reg, occ| occ[reg] += 1 }
    puts "sample: #{seed_regions}"
    seed_regions.each do |region, count|
      region_participants = group_participants.select { |p| p[:region] == region }
      region_participants = region_participants.sort_by { |p| p[:network_size] }.reverse
      group_seeds += region_participants.take(count)
    end
    # # first pass
    # group_participants.each do |participant|
    #   break if group_seeds.length >= 10

    #   unless represented_regions.include?(participant[:region])
    #     group_seeds << participant
    #     represented_regions << participant[:region]
    #   end
    # end
    # # second pass
    # if group_seeds.length < 10
    #   group_participants.each do |participant|
    #     break if group_seeds.length >= 10
    #     next if group_seeds.include?(participant)

    #     if represented_regions.count(participant[:region]) < 2
    #       group_seeds << participant
    #       represented_regions << participant[:region]
    #     end
    #   end
    # end
    seeds << group_seeds
    # puts "group: #{sgm_group} => #{group_seeds.length}"
    # puts "regions: #{sgm_group} => #{group_seeds.pluck(:region)}"

    # alternative seeds
    puts "alternative seeds for #{sgm_group}"
    sample_regions = region_list.sample(10)
    puts "sample regions: #{sample_regions}"
    seed_regions = sample_regions.each_with_object(Hash.new(0)) { |reg, occ| occ[reg] += 1 }
    puts "sample: #{seed_regions}"
    seed_regions.each do |region, count|
      region_participants = group_participants.select { |p| p[:region] == region }
      region_participants = region_participants.sort_by { |p| p[:network_size] }.reverse
      r_count = 0
      region_participants.each do |participant|
        break if r_count >= count
        next if group_seeds.include?(participant)

        alt_group_seeds << participant
        r_count += 1
      end
    end
    # represented_regions = []
    # # first pass
    # group_participants.each do |participant|
    #   break if alt_group_seeds.length >= 10
    #   next if group_seeds.include?(participant)

    #   unless represented_regions.include?(participant[:region])
    #     alt_group_seeds << participant
    #     represented_regions << participant[:region]
    #   end
    # end
    # # second pass
    # if alt_group_seeds.length < 10
    #   group_participants.each do |participant|
    #     break if alt_group_seeds.length >= 10
    #     next if alt_group_seeds.include?(participant)
    #     next if group_seeds.include?(participant)

    #     if represented_regions.count(participant[:region]) < 2
    #       alt_group_seeds << participant
    #       represented_regions << participant[:region]
    #     end
    #   end
    # end
    alt_seeds << alt_group_seeds
    # puts "group: #{sgm_group} => #{alt_group_seeds.length}"
    # puts "regions: #{sgm_group} => #{alt_group_seeds.pluck(:region)}"
  end

  # write seeds to csv file
  CSV.open('data/vietnam_seeds_weighted.csv', 'w') do |csv|
    csv << ['Seeds']
    csv << %w[code sgm_group region network_size locality]
    seeds.each do |group_seeds|
      group_seeds.each do |seed|
        csv << [seed[:code], seed[:sgm_group], seed[:region],
                seed[:network_size] == -1 ? '' : seed[:network_size],
                seed[:locality]]
      end
    end
    csv << []
    csv << ['Alternate Seeds']
    csv << %w[code sgm_group region network_size locality]
    alt_seeds.each do |group_seeds|
      group_seeds.each do |seed|
        csv << [seed[:code], seed[:sgm_group], seed[:region],
                seed[:network_size] == -1 ? '' : seed[:network_size],
                seed[:locality]]
      end
    end
  end
end
