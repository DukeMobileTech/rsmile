module SurveyResponses
  class Agency
    def stats(country)
      stats = []
      baselines = SurveyResponse.eligible_completed_main_block.where(country: country)
      SurveyResponse::ELIGIBLE_SGM_GROUPS.each do |group|
        group_baselines = baselines.select { |baseline| baseline.sgm_group == group }
        row = row_data(group, group_baselines)
        stats << row
      end
      stats
    end

    private

    def row_data(group, group_baselines)
      row = {
        group: group,
        recruited: group_baselines.size
      }
      source_stats = baseline_source_stats(group_baselines)
      (12..24).each do |source|
        row[source.to_s] = source_stats[source.to_s]&.size || 0
      end
      row
    end

    def baseline_source_stats(group_baselines)
      stats = {}
      group_baselines.each do |baseline|
        baseline.source&.split(',')&.each do |source|
          list = stats[source] ||= []
          stats[source] = list << baseline
        end
      end
      stats
    end
  end
end
