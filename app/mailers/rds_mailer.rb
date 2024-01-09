class RdsMailer < ApplicationMailer
  default from: email_address_with_name(Rails.application.credentials.config[:default_from_email],
                                        Rails.application.credentials.config[:from_name])

  def start_rds_email
    @participant = params[:participant]
    @participant.reminders.create(channel: 'Email', category: Participant::INITIAL)
    mail(to: @participant.email, subject: 'SMILE Study Recruitment')
  end
end
