module Participants
  class Source
    def stats(country)
      source_count = {}
      25.times do |hf|
        next if hf == 3 && country != 'Brazil'
        next if hf == 9 && country == 'Vietnam'
        next if country != 'Vietnam' &&
                [10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].include?(hf)

        count1 = source_counts(hf, eligible(country))
        count2 = source_counts(hf, ineligible(country))
        count3 = source_counts(hf, derived(country))
        source_count[hf.to_s] = { eligible: count1, ineligible: count2, derived: count3 } if (count1 + count2 + count3).positive?
      end
      source_count
    end

    def timeline(country)
      Groupdate.week_start = :monday
      weeks = SortedSet.new
      sources = weekly_recruitment_by_source(country, weeks)
      weekly_recruitment_filled(sources, weeks)
    end

    private

    def eligible(country)
      Participant.eligible_completed_main_block.where(country: country)
    end

    def ineligible(country)
      Participant.ineligible.where(country: country)
    end

    def derived(country)
      Participant.derived.where(country: country)
    end

    def source_counts(num, participants)
      if num.zero?
        participants.select { |p| p.baseline&.source&.blank? }.size
      else
        participants.select { |p| p.baseline&.source&.split(',')&.include?(num.to_s) }.size
      end
    end

    def weekly_recruitment_by_source(country, weeks)
      sources = {}
      25.times do |num|
        next if num == 3 && country != 'Brazil'
        next if num == 9 && country == 'Vietnam'
        next if country != 'Vietnam' && [10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].include?(num)

        pbs = participants_by_source(num, eligible(country))
        weeklies = weekly_recruitment(pbs, weeks)
        sources[num] = weeklies
      end
      sources
    end

    def participants_by_source(num, participants)
      if num.zero?
        participants.select { |p| p.baseline.source.blank? }
                    .group_by_week(format: '%m/%d/%y') { |r| r.created_at }
                    .transform_values(&:count)
      else
        participants.select { |r| r.baseline&.source&.split(',')&.include?(num.to_s) }
                    .group_by_week(format: '%m/%d/%y') { |r| r.created_at }
                    .transform_values(&:count)
      end
    end

    def weekly_recruitment(pbs, weeks)
      weeklies = {}
      pbs.each do |week, count|
        next unless count.positive?

        weeklies[week] = count
        weeks << Date.strptime(week, '%m/%d/%y')
      end
      weeklies
    end

    def weekly_recruitment_filled(sources, weeks)
      final_sources = {}
      sources.each do |source, weeklies|
        next if weeklies.blank?

        source_week_list = []
        weeks.each do |week|
          source_week_list << week_list(weeklies, week.strftime('%m/%d/%y'))
        end
        final_sources[source] = source_week_list
      end
      final_sources
    end

    def week_list(weeklies, str)
      if weeklies[str].nil?
        { str => 0 }
      else
        { str => weeklies[str] }
      end
    end
  end
end
