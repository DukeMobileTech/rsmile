module SurveyResponses
  class Mobilizer
    def stats(country)
      mobilizers = SurveyResponse.baselines.where(country: country)
                                 .where('metadata ? :key', key: 'referee_code')
      codes = mobilizers.map(&:referee_code).uniq.sort
      data = []
      codes.each do |code|
        data << mobilizer_data(code, mobilizers)
      end
      data
    end

    private

    def mobilizer_baselines(mobilizers, code)
      mobilizers.where('metadata @> hstore(:key, :value)',
                       key: 'referee_code', value: code)
    end

    def mobilizer_data(code, mobilizers)
      baselines = mobilizer_baselines(mobilizers, code)
      participant_ids = baselines.pluck(:participant_id).compact.uniq
      {
        code: code,
        survey_count: baselines.size,
        duplicate_count: baselines.where(duplicate: true).size,
        participant_count: participant_ids.size,
        average_participant_baselines: average_baselines_per_mobilizer_participant(baselines, participant_ids)
      }
    end

    def average_baselines_per_mobilizer_participant(baselines, participant_ids)
      counts = []
      participant_ids.each do |participant_id|
        counts << baselines.where(participant_id: participant_id).size
      end
      (counts.sum / counts.size.to_f).round(2)
    end
  end
end
