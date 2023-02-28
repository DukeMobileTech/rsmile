class RecruitmentReminderJob < ApplicationJob
  queue_as :sgm_pilot

  def perform(participant_id)
    participant = Participant.find_by(id: participant_id)
    return if participant.nil?
    return if participant.raffle_quota_met
    return if participant.reminder_quota_met

    to = participant.phone_number
    to.prepend('+1') if to[0] != '+'
    from = Rails.application.credentials.config[:TWILIO_NUMBER]
    body = "Hi #{participant.first_name}! This is a reminder from the SMILE SGM Pilot Study at Duke " +
           'that you still have an opportunity to recruit other LGBTQ+ participants who identify as ' +
           "#{participant.sgm_group} to also take the survey. For each of the first five people you recruit " +
           'who successfully completes the survey, you will receive 1 extra raffle entry for one of four $250 cash prizes. ' +
           'Please share with them the following invitation link: ' +
           "#{Rails.application.credentials.config[:invitation_url]}?referrer_code=#{participant.code}"
    account_sid = Rails.application.credentials.config[:TWILIO_SID]
    auth_token = Rails.application.credentials.config[:TWILIO_AUTH]
    client = Twilio::REST::Client.new(account_sid, auth_token)
    begin
      client.messages.create(
        from: from,
        to: to,
        body: body
      )
      return if participant.reminder_quota_met

      count = participant.reminders.size + 1
      participant.reminders.create(category: count)
    rescue Twilio::REST::RestError => e
      Rails.logger.error e.message
    end
  end
end
