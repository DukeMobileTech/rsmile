module SurveyResponses
  class Agency
    def stats(country)
      stats = []
      baselines = SurveyResponse.eligible_completed_main_block.where(country: country)
      SurveyResponse::ELIGIBLE_SGM_GROUPS.each do |group|
        group_baselines = baselines.select { |baseline| baseline.sgm_group == group }
        row = {
          'SGM Group': group,
          Recruited: group_baselines.size
        }
        source_stats = {}
        group_baselines.each do |baseline|
          baseline.source&.split(',')&.each do |source|
            list = source_stats[source] ||= []
            source_stats[source] = list << baseline
          end
        end
        (12..24).each do |source|
          row[SurveyResponse::SOURCES[source.to_s]] = source_stats[source.to_s]&.size || 0
        end
        stats << row
      end
      stats
    end
  end
end
