module SurveyResponses
  class Baseline
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def stats(country)
      all = surveys(country)
      {
        All: all.size,
        Completed: all.where(survey_complete: true).size,
        Partials: all.where.not(survey_complete: true).size,
        Eligible: eligible(country).size,
        Ineligible: ineligible(country).size,
        Duplicates: duplicates(country).size,
        Excluded: excluded(country).size,
        Derived: derived(country).size
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def surveys(country)
      SurveyResponse.baselines.where(country: country)
    end

    def eligible(country)
      SurveyResponse.eligible_baselines.where(country: country)
    end

    def ineligible(country)
      SurveyResponse.ineligible_baselines.where(country: country)
    end

    def duplicates(country)
      SurveyResponse.duplicate_baselines.where(country: country)
    end

    def excluded(country)
      SurveyResponse.excluded_baselines.where(country: country)
    end

    def derived(country)
      SurveyResponse.attraction_eligible_baselines.where(country: country)
    end
  end
end
