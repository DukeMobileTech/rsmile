class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.config[:from_email]
  layout 'mailer'
end
