class ReminderMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:default_from_email],
                                        Rails.application.credentials.config[:default_from_name])
  before_action :set_participant
  after_action :set_language

  def post_baseline
    @participant.reminders.create(channel: 'Email', category: Participant::FIRST)
    mail(to: @participant.email, subject: I18n.t('rds.post_survey', locale: @language))
  end

  def post_baseline_reminder
    if @participant.recruitment_quota_met
      payment
    else
      @participant.reminders.create(channel: 'Email', category: Participant::SECOND)
      mail(to: @participant.email, subject: I18n.t('rds.post_survey_reminder', locale: @language))
    end
  end

  def payment
    @participant.reminders.create(channel: 'Email', category: Participant::THIRD)
    mail(to: @participant.email, subject: I18n.t('rds.payment', locale: @language))
  end

  def gratitude
    @participant.reminders.create(channel: 'Email', category: Participant::FOURTH)
    mail(to: @participant.email, subject: I18n.t('rds.gratitude', locale: @language))
  end

  private

  def set_participant
    @participant = params[:participant]
  end

  def set_language
    @language = 'en'
  end
end
