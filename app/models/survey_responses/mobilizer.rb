module SurveyResponses
  class Mobilizer
    def stats(country)
      mobilizers = SurveyResponse.baselines.where(country: country)
                                 .where('metadata ? :key', key: 'mobilizer_code')
      codes = mobilizers.map(&:mobilizer_code).uniq.sort
      data = []
      codes.each do |code|
        data << mobilizer_data(code, mobilizers)
      end
      data
    end

    private

    def mobilizer_baselines(mobilizers, code)
      mobilizers.where('metadata @> hstore(:key, :value)',
                       key: 'mobilizer_code', value: code)
    end

    def mobilizer_data(code, mobilizers)
      baselines = mobilizer_baselines(mobilizers, code)
      participant_ids = baselines.pluck(:participant_id).compact.uniq
      {
        code: code,
        survey_count: baselines.size,
        duplicate_count: baselines.where(duplicate: true).size,
        participant_count: participant_ids.size,
        average_participant_baselines: average_baselines_per_mobilizer_participant(baselines, participant_ids),
        average_duration: average_duration(baselines),
        ip_address_count: mobilizer_ip_addresses(baselines, code).size,
      }
    end

    def average_baselines_per_mobilizer_participant(baselines, participant_ids)
      counts = []
      participant_ids.each do |participant_id|
        counts << baselines.where(participant_id: participant_id).size
      end
      (counts.sum / counts.size.to_f).round(2)
    end

    def average_duration(baselines)
      durations = baselines.map { |baseline| baseline&.duration&.to_i }.compact
      avg = (durations.sum / durations.size.to_f)
      (avg / 60).ceil
    end

    def mobilizer_ip_addresses(baselines, code)
      baselines.where('metadata @> hstore(:key, :value)',
                       key: 'mobilizer_code', value: code)
                .map(&:ip_address).compact.uniq
    end
  end
end
