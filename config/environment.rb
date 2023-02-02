# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Using SendGrid
ActionMailer::Base.smtp_settings = {
  user_name: Rails.application.credentials.config[:SMTP_USERNAME],
  password: Rails.application.credentials.config[:SMTP_PASSWORD],
  domain: Rails.application.credentials.config[:SMTP_DOMAIN],
  address: Rails.application.credentials.config[:SMTP_ADDRESS],
  port: Rails.application.credentials.config[:SMTP_PORT],
  authentication: :plain,
  enable_starttls_auto: true
}
