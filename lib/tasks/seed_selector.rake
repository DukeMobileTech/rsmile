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
    group_participants = participants.select { |p| p[:sgm_group] == sgm_group }
    regions_list = group_participants.pluck(:region)
    # preference seeds to large population regions
    large_region_picks = [3, 2, 2].shuffle
    hcmc_picks = large_region_picks[0]
    hanoi_picks = large_region_picks[1]
    seed_regions = {
      'Ho Chi Minh City' => hcmc_picks,
      'Hanoi' => hanoi_picks
    }
    # remove hcmc and hanoi from regions_list
    seed_regions.each_key do |region|
      regions_list.reject! { |r| r == region }
    end
    # apportion remaining picks to other regions
    other_regions_picks = 10 - hcmc_picks - hanoi_picks
    raffle_regions = []
    regions_list.uniq.each do |region|
      region_participants = group_participants.select { |p| p[:region] == region }
      region_count = ((region_participants.size / group_participants.size.to_f) * other_regions_picks).round
      seed_regions[region] = region_count if region_count.positive?
      raffle_regions << region if region_count.zero?
    end
    raffle_count = 10 - seed_regions.values.sum
    if raffle_count.positive?
      raffle_regions.shuffle.take(raffle_count).each do |region|
        seed_regions[region] = 1
      end
    end
    puts "#{sgm_group}: sampled seed regions: #{seed_regions}"
    # select seeds with largest network size in each region
    seed_regions.each do |region, count|
      region_participants = group_participants.select { |p| p[:region] == region }
      region_participants = region_participants.sort_by { |p| p[:network_size] }.reverse
      group_seeds += region_participants.take(count)
      alt_group_seeds += region_participants[count, count]
    end
    seeds << group_seeds
    alt_seeds << alt_group_seeds
  end
  # write seeds to csv file
  CSV.open('data/vietnam_seeds_portioned.csv', 'w') do |csv|
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
