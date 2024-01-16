module SurveyResponses
  class Source
    def stats(country)
      source_count = {}
      27.times do |hf|
        next if skip(country, hf)

        count1, count2, count3 = category_counts(hf, country)
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

    def skip(country, num)
      ([3, 25, 26, 27, 28, 29].include?(num) && country != 'Brazil') ||
        (num == 9 && country == 'Vietnam') ||
        (country != 'Vietnam' && [10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].include?(num))
    end

    def category_counts(number, country)
      [source_counts(number, eligible(country)), source_counts(number, ineligible(country)), source_counts(number, derived(country))]
    end

    def eligible(country)
      SurveyResponse.eligible_completed_main_block.where(country: country)
    end

    def ineligible(country)
      SurveyResponse.ineligible_baselines.where(country: country)
    end

    def derived(country)
      SurveyResponse.attraction_eligible_baselines.where(country: country)
    end

    def source_counts(num, baselines)
      if num.zero?
        baselines.select { |b| b.source&.blank? }.size
      else
        baselines.select { |b| b.source&.split(',')&.include?(num.to_s) }.size
      end
    end

    def weekly_recruitment_by_source(country, weeks)
      sources = {}
      27.times do |num|
        next if skip(country, num)

        baselines = baselines_by_source(num, eligible(country))
        weeklies = weekly_recruitment(baselines, weeks)
        sources[num] = weeklies
      end
      sources
    end

    def baselines_by_source(num, baselines)
      if num.zero?
        blanks(baselines)
      else
        non_blanks(baselines, num)
      end
    end

    def blanks(baselines)
      baselines.select { |b| b.source.blank? }
               .group_by_week(format: '%m/%d/%y', &:created_at)
               .transform_values(&:count)
    end

    def non_blanks(baselines, num)
      baselines.select { |b| b.source&.split(',')&.include?(num.to_s) }
               .group_by_week(format: '%m/%d/%y', &:created_at)
               .transform_values(&:count)
    end

    def weekly_recruitment(baselines, weeks)
      weeklies = {}
      baselines.each do |week, count|
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
