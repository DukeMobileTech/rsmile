Clearance.configure do |config|
  config.mailer_sender = "noreply@chpir.org"
  config.rotate_csrf_on_sign_in = true
  config.cookie_expiration = lambda { |cookies| 1.hour.from_now.utc }
end
