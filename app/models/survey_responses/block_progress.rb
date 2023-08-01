module SurveyResponses
  class BlockProgress
    def progress(country)
      {
        'Started Short Survey': started_stats(country),
        'Completed Main Block': main_block_stats(country),
        'Completed Group A': group_a_stats(country),
        'Completed Group B': group_b_stats(country),
        'Completed Group C': group_c_stats(country)
      }
    end

    private

    def ineligible_sgm_groups
      SurveyResponse::INELIGIBLE_SGM_GROUPS
    end

    def started_stats(country)
      started = SurveyResponse.started_short_survey.where(country: country)
      eligible_started = started.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
      [started.size, eligible_started.size]
    end

    def main_block_stats(country)
      main_block = SurveyResponse.completed_main_block.where(country: country)
      eligible_main_block = main_block.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
      [main_block.size, eligible_main_block.size]
    end

    def group_a_stats(country)
      group_a = SurveyResponse.completed_group_a.where(country: country)
      eligible_group_a = group_a.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
      [group_a.size, eligible_group_a.size]
    end

    def group_b_stats(country)
      group_b = SurveyResponse.completed_group_b.where(country: country)
      eligible_group_b = group_b.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
      [group_b.size, eligible_group_b.size]
    end

    def group_c_stats(country)
      group_c = SurveyResponse.completed_group_c.where(country: country)
      eligible_group_c = group_c.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
      [group_c.size, eligible_group_c.size]
    end
  end
end
