Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
  # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  
  # Enable performance monitoring
  config.enable_tracing = true
  
  # Filter out sensitive data
  config.before_send = lambda do |event, hint|
    # Filter out sensitive parameters
    if event.request && event.request.data
      event.request.data = event.request.data.except(
        'password', 'password_confirmation', 'token', 'api_key'
      )
    end
    event
  end
  
  # Set environment
  config.environment = Rails.env
  
  # Enable debug mode in development
  config.debug = Rails.env.development?
end 