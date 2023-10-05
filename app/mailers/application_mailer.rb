class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(Rails.application.credentials.config[:from_email],
                                        Rails.application.credentials.config[:EMAIL_PREFIX])
  layout 'mailer'
end
