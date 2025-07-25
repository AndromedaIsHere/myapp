require "sidekiq"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
  
  # Configure Sentry for Sidekiq
  config.error_handlers << proc do |ex, context|
    Sentry.capture_exception(ex, extra: context) if defined?(Sentry)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end 