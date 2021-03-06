Clearance.configure do |config|
  config.mailer_sender = Rails.application.credentials.config[:from_email]
  config.rotate_csrf_on_sign_in = true
  config.cookie_expiration = lambda { |cookies| 1.hour.from_now.utc }
  config.allow_sign_up = false
end
