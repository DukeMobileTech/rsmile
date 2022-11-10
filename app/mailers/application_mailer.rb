class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.config[:default_from_email]
  layout 'mailer'
end
