class ReminderMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:from_email],
                                        Rails.application.credentials.config[:from_name])
  before_action :set_participant
  after_action :set_reminder_count

  def one
    mail(to: @participant.email, subject: 'SMILE Study - First Recruitment Reminder')
  end

  def two
    if @participant.recruitment_quota_met
      three
    else
      mail(to: @participant.email, subject: 'SMILE Study - Second Recruitment Reminder')
    end
  end

  def three
    mail(to: @participant.email, subject: 'SMILE Study - Thank You')
  end

  def four
    mail(to: @participant.email, subject: 'SMILE Study - Thank You')
  end

  private

  def set_participant
    @participant = params[:participant]
  end

  def set_reminder_count
    return if @participant.reminder_quota_met

    count = @participant.reminders.size + 1
    @participant.reminders.create(category: count)
  end
end
