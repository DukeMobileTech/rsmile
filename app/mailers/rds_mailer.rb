class RdsMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:default_from_email],
                                        Rails.application.credentials.config[:default_from_name])

  before_action :set_participant
  before_action :set_language

  def invite_initial
    @participant.reminders.create(channel: 'Email', category: Participant::INITIAL)
    mail(to: @participant.email, subject: I18n.t('rds.invite_initial', locale: @language))
  end

  def invite_reminder
    return unless @participant.seed_consents.empty?
    return if @participant.opt_out

    @participant.reminders.create(channel: 'Email', category: Participant::REMIND)
    mail(to: @participant.email, subject: I18n.t('rds.invite_reminder', locale: @language))
  end

  def post_consent
    return unless @participant.agree_to_recruit

    @participant.reminders.create(channel: 'Email', category: Participant::FIRST)
    mail(to: @participant.email, subject: I18n.t('rds.post_survey', locale: @language))
  end

  def post_consent_reminder
    return unless @participant.agree_to_recruit

    if @participant.recruitment_quota_met
      payment
    else
      @participant.reminders.create(channel: 'Email', category: Participant::SECOND)
      mail(to: @participant.email, subject: I18n.t('rds.post_survey_reminder', locale: @language))
    end
  end

  def payment
    return unless @participant.agree_to_recruit

    if @participant.wants_payment
      @participant.reminders.create(channel: 'Email', category: Participant::THIRD)
      mail(to: @participant.email, subject: I18n.t('rds.payment', locale: @language))
    else
      gratitude
    end
  end

  def gratitude
    return unless @participant.agree_to_recruit

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
