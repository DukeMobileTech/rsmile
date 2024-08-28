module Participants
  class Payments
    def file
      tempfile = Tempfile.new(Time.now.to_i.to_s)
      CSV.open(tempfile.path, 'wb') do |csv|
        csv << header
        participants.each do |participant|
          csv << row(participant)
        end
      end
      tempfile
    end

    private

    def header
      %w[ID Email PhoneNumber Code QuotaMet Seed DerivedSeed
         AlternateSeed SurveyCompleted Invitees PaymentAmount Paid]
    end

    def participants
      Participant.where(country: 'Vietnam')
                 .where(baseline_participant_id: nil)
                 .or(Participant.where(seed: true))
                 .or(Participant.where(alternate_seed: true))
    end

    def row(participant)
      [participant.id, participant.email, participant.formatted_phone_number,
       participant.code, participant.recruitment_quota_met,
       participant.seed, participant.derived_seed, participant.alternate_seed,
       participant.baseline_complete?, participant.recruits.pluck(:code).join('; '),
       participant.payment_amount, false]
    end
  end
end
