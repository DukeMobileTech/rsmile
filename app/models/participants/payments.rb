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
      %w[ID Email PhoneNumber SurveyDone Invitees DueDate PaymentAmount Paid PaymentDate]
    end

    def participants
      Participant.where(country: 'Vietnam')
                 .where(baseline_participant_id: nil)
                 .or(Participant.where(seed: true))
                 .or(Participant.where(alternate_seed: true))
    end

    def row(participant)
      [participant.id, participant.email, participant.formatted_phone_number,
       participant.baseline_complete?, participant.eligible_completed_recruits.size,
       participant.due_on&.strftime('%Y-%m-%d'), participant.payment_amount, false, nil]
    end
  end
end
