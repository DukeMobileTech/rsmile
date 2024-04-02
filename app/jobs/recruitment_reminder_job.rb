class RecruitmentReminderJob < ApplicationJob
  queue_as :rds

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Style/CaseLikeIf, Metrics/PerceivedComplexity
  def perform(participant_id, round)
    participant = Participant.find_by(id: participant_id)
    nil if participant.nil?

    if round == 'seed_initial'
      seed_invite_initial(participant)
    elsif round == 'seed_reminder'
      seed_invite_reminder(participant)
    elsif round == 'seed_post_consent'
      seed_post_consent(participant)
    elsif round == 'seed_post_consent_reminder'
      seed_post_consent_reminder(participant)
    elsif round == 'participant_post_consent'
      participant_post_consent(participant)
    elsif round == 'participant_post_consent_reminder'
      participant_post_consent_reminder(participant)
    elsif round == 'payment'
      payment(participant)
    elsif round == 'gratitude'
      gratitude(participant)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Style/CaseLikeIf, Metrics/PerceivedComplexity

  def seed_invite_initial(participant)
    url = "#{Rails.application.credentials.config[:seeds_consent_url]}?code=#{participant.code}"
    body = I18n.t('rds.sms.seed_invite_initial', url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def seed_invite_reminder(participant)
    return unless participant.invite_reminder_met?

    url = "#{Rails.application.credentials.config[:seeds_consent_url]}?code=#{participant.code}"
    body = I18n.t('rds.sms.seed_invite_reminder', url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def seed_post_consent(participant)
    url = "#{Rails.application.credentials.config[:consent_url]}?referrer_code=#{participant.code}"
    body = I18n.t('rds.sms.seed_post_consent', sgm_group: participant.sgm_group_label,
                                               url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def seed_post_consent_reminder(participant)
    return if participant.recruitment_quota_met || !participant.agree_to_recruit

    url = "#{Rails.application.credentials.config[:consent_url]}?referrer_code=#{participant.code}"
    body = I18n.t('rds.sms.seed_post_consent_reminder', sgm_group: participant.sgm_group_label,
                                                        url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def participant_post_consent(participant)
    url = "#{Rails.application.credentials.config[:consent_url]}?referrer_code=#{participant.code}"
    body = I18n.t('rds.sms.participant_post_consent', sgm_group: participant.sgm_group_label,
                                                      url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def participant_post_consent_reminder(participant)
    return if participant.recruitment_quota_met || !participant.agree_to_recruit

    url = "#{Rails.application.credentials.config[:consent_url]}?referrer_code=#{participant.code}"
    body = I18n.t('rds.sms.participant_post_consent_reminder', sgm_group: participant.sgm_group_label,
                                                               url: url, locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  def payment(participant)
    return unless participant.agree_to_recruit
    return unless participant.wants_payment
    return unless participant.participated?

    to = participant.formatted_phone_number
    body = I18n.t('rds.sms.payment', amount: participant.payment_amount,
                                     country: participant.country, number: to,
                                     contact: participant.country_contact,
                                     locale: participant.locale)
    send_message(to, body)
  end

  def gratitude(participant)
    return unless !participant.agree_to_recruit || !participant.wants_payment || !participant.participated?

    body = I18n.t('rds.sms.gratitude', country: participant.country,
                                       contact: participant.country_contact,
                                       locale: participant.locale)
    send_message(participant.formatted_phone_number, body)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def send_message(to, body)
    from = Rails.application.credentials.config[:RDS_TWILIO_NUMBER]
    account_sid = Rails.application.credentials.config[:TWILIO_SID]
    auth_token = Rails.application.credentials.config[:TWILIO_AUTH]
    client = Twilio::REST::Client.new(account_sid, auth_token)
    client.messages.create(
      from: from,
      to: to,
      body: body
    )
  rescue Twilio::REST::RestError => e
    Rails.logger.error e.message
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
