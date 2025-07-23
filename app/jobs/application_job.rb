class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  
  # Add Sentry error tracking to jobs
  rescue_from StandardError do |exception|
    Sentry.capture_exception(exception, extra: {
      job_class: self.class.name,
      arguments: arguments
    }) if defined?(Sentry)
    raise
  end
end
