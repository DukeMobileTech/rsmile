module SurveyResponses
  class Mobilizer
    def stats(country)
      baselines = SurveyResponse.baselines.where(country: country)
                                .where('metadata ? :key', key: 'mobilizer_code')
      codes = baselines.map(&:mobilizer_code).uniq.sort
      data = []
      codes.each do |code|
        data << mobilizer_data(code, baselines)
      end
      data
    end

    private

    def mobilizer_baselines(baselines, code)
      baselines.where('metadata @> hstore(:key, :value)',
                      key: 'mobilizer_code', value: code)
    end

    # rubocop:disable Metrics/MethodLength
    def mobilizer_data(code, survey_responses)
      baselines = mobilizer_baselines(survey_responses, code)
      participant_ids = baselines.pluck(:participant_id).compact.uniq
      accepted_baselines = mobilizer_accepted_baselines(baselines)
      {
        code: code,
        survey_count: baselines.size,
        duplicate_count: baselines.where(duplicate: true).size,
        participant_count: participant_ids.size,
        average_participant_baselines: average_baselines_per_mobilizer_participant(baselines, participant_ids),
        average_duration: average_duration(baselines),
        ip_address_count: mobilizer_ip_addresses(baselines, code).size,
        accepted_participant_count: accepted_baselines.size,
        group_a_count: group_count(baselines, 'group_a'),
        group_b_count: group_count(baselines, 'group_b'),
        group_c_count: group_count(baselines, 'group_c')
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
      durations = durations.map { |duration| [duration, 9000].min } # Cap at 150 minutes
      avg = (durations.sum / durations.size.to_f)
      (avg / 60).ceil
    end

    def mobilizer_ip_addresses(baselines, code)
      baselines.where('metadata @> hstore(:key, :value)',
                      key: 'mobilizer_code', value: code)
               .map(&:ip_address).compact.uniq
    end

    def mobilizer_accepted_baselines(baselines)
      baselines.where(duplicate: false)
               .where.not(participant_id: Participant.excluded.pluck(:id) + [nil])
               .where('(metadata -> :key) IN (:values)', key: 'sgm_group', values: Participant::ELIGIBLE_SGM_GROUPS)
               .where('metadata @> hstore(:key, :value)', key: 'main_block', value: 'true')
    end

    def group_count(baselines, group)
      baselines.where('metadata @> hstore(:key, :value)',
                      key: group, value: 'true').size
    end
  end
end
