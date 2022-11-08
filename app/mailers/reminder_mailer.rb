class ReminderMailer < ApplicationMailer
  after_action :set_reminder_count

  def reminder_email
    @participant = params[:participant]
    return if @participant.raffle_quota_met
    return if @participant.reminder_quota_met

    mail(to: @participant.email, subject: 'SGM Pilot Recruitment Reminder')
  end

  private

  def set_reminder_count
    return if @participant.reminder_quota_met

    count = @participant.reminders.size + 1
    @participant.reminders.create(category: count)
  end
end
