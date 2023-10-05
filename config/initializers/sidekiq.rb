url = "redis://localhost:6379/#{Rails.application.credentials.config[:REDIS_DB]}"

Sidekiq.configure_server do |config|
  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
