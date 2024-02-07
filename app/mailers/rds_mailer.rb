class RdsMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:default_from_email],
                                        Rails.application.credentials.config[:from_name])

  before_action :set_participant

  def start
    @participant.reminders.create(channel: 'Email', category: Participant::INITIAL)
    mail(to: @participant.email, subject: 'SMILE Study Recruitment')
  end

  def remind
    return unless @participant.agree_to_recruit

    if @participant.recruits.empty?
      start
    elsif @participant.recruitment_quota_met
      payment
    else
      @participant.reminders.create(channel: 'Email', category: Participant::SECOND)
      mail(to: @participant.email, subject: 'SMILE Study - Second Recruitment Reminder')
    end
  end

  def payment
    return unless @participant.agree_to_recruit

    if @participant.wants_payment
      @participant.reminders.create(channel: 'Email', category: Participant::THIRD)
      mail(to: @participant.email, subject: 'SMILE Study - Thank You')
    else
      thanks
    end
  end

  def thanks
    return unless @participant.agree_to_recruit

    @participant.reminders.create(channel: 'Email', category: Participant::FOURTH)
    mail(to: @participant.email, subject: 'SMILE Study - Thank You')
  end

  private

  def set_participant
    @participant = params[:participant]
  end
end
