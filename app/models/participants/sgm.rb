module Participants
  class Sgm
    def eligible_stats(country)
      stats = {}
      participants = Participant.eligible_completed_main_block.where(country: country)
      Participant::ELIGIBLE_SGM_GROUPS.each do |group|
        stats[group] = participants.count { |participant| participant.sgm_group == group }
      end
      stats
    end

    def ineligible_stats(country)
      stats = {}
      participants = Participant.ineligible.where(country: country)
      Participant::INELIGIBLE_SGM_GROUPS.each do |group|
        stats[group] = participants.count { |participant| participant.sgm_group == group }
      end
      stats
    end

    def blank_stats(kountry)
      participants = Participant.blanks.where(country: kountry)
      no_baseline, baseline_started = baseline_status(participants)
      { 'Contact Info completed but Baseline not started': no_baseline.size,
        'Baseline started but SOGI not completed': baseline_started.size }
    end

    private

    def baseline_status(participants)
      no_baseline = []
      baseline_started = []
      participants.each do |part|
        if !part.contacts.empty? & part.baselines.empty?
          no_baseline << part
        elsif !part.baselines.empty?
          baseline_started << part
        end
      end
      [no_baseline, baseline_started]
    end
  end
end
