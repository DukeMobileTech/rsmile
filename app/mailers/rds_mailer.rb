class RdsMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:default_from_email],
                                        Rails.application.credentials.config[:default_from_name])

  before_action :set_participant
  before_action :set_language

  def invite_initial
    @mail = mail(to: @participant.email, subject: I18n.t('rds.invite_initial', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::INITIAL, message: @mail.body.encoded)
  end

  def invite_reminder
    return unless @participant.invite_reminder_met?

    @mail = mail(to: @participant.email, subject: I18n.t('rds.invite_reminder', locale: @language))
    RecruitmentReminderJob.perform_now(@participant.id, 'seed_reminder2')
    @participant.reminders.create(channel: 'Email', category: Participant::REMIND, message: @mail.body.encoded)
  end

  def invite_reminder2
    return unless @participant.invite_reminder_met?

    @mail = mail(to: @participant.email, subject: I18n.t('rds.invite_reminder', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::REMIND, message: @mail.body.encoded)
  end

  def post_consent
    return unless @participant.agree_to_recruit

    @mail = mail(to: @participant.email, subject: I18n.t('rds.post_survey', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::FIRST, message: @mail.body.encoded)
  end

  def post_consent_reminder
    return if @participant.recruitment_quota_met || !@participant.agree_to_recruit

    @mail = mail(to: @participant.email, subject: I18n.t('rds.post_survey_reminder', locale: @language))
    RecruitmentReminderJob.perform_now(@participant.id, 'seed_post_consent_reminder2') if @participant.eligible_completed_recruits.empty?
    @participant.reminders.create(channel: 'Email', category: Participant::SECOND, message: @mail.body.encoded)
  end

  def post_consent_reminder2
    return if @participant.recruitment_quota_met || !@participant.agree_to_recruit

    @mail = mail(to: @participant.email, subject: I18n.t('rds.post_survey_reminder', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::SECOND, message: @mail.body.encoded)
  end

  def payment
    return unless @participant.agree_to_recruit
    return unless @participant.wants_payment
    return unless @participant.participated?

    @mail = mail(to: @participant.email, subject: I18n.t('rds.payment', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::THIRD, message: @mail.body.encoded)
  end

  def gratitude
    return unless !@participant.agree_to_recruit || !@participant.wants_payment || !@participant.participated?

    @mail = mail(to: @participant.email, subject: I18n.t('rds.gratitude', locale: @language))
    @participant.reminders.create(channel: 'Email', category: Participant::FOURTH, message: @mail.body.encoded)
  end

  private

  def set_participant
    @participant = params[:participant]
  end

  def set_language
    @language = @participant.locale
  end
end
