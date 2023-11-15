module Participants
  class SgmTimeline
    def stats(country)
      Groupdate.week_start = :monday
      weeks = SortedSet.new
      participants = Participant.eligible_completed_main_block.where(country: country)
      data = sgm_weekly(participants, weeks)
      weekly_recruitment_filled(data, weeks)
    end

    private

    def sgm_weekly(participants, weeks)
      stats = {}
      Participant::ELIGIBLE_SGM_GROUPS.each do |sgm_group|
        group_participants = participants.select { |baseline| baseline.sgm_group == sgm_group }
        group_weekly_count = group_participants.group_by_week(format: '%m/%d/%y', &:created_at).transform_values(&:count)
        weeklies = weekly_recruitment(group_weekly_count, weeks)
        stats[sgm_group] = weeklies
      end
      stats
    end

    def weekly_recruitment(data, weeks)
      weeklies = {}
      data.each do |week, count|
        next unless count.positive?

        weeklies[week] = count
        weeks << Date.strptime(week, '%m/%d/%y')
      end
      weeklies
    end

    def weekly_recruitment_filled(groups, weeks)
      final_groups = {}
      groups.each do |group, weeklies|
        group_week_list = []
        weeks.each do |week|
          group_week_list << week_list(weeklies, week.strftime('%m/%d/%y'))
        end
        final_groups[group] = group_week_list
      end
      final_groups
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
