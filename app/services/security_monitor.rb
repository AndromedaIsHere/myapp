class SecurityMonitor
  def self.track_security_event(event_type, details = {})
    Sentry.capture_message(
      "Security Event: #{event_type}",
      level: :warning,
      extra: details
    ) if defined?(Sentry)
  end

  def self.track_failed_login(ip, email)
    track_security_event('failed_login', {
      ip: ip,
      email: email,
      timestamp: Time.current
    })
  end

  def self.track_suspicious_activity(ip, activity_type, details = {})
    track_security_event('suspicious_activity', {
      ip: ip,
      activity_type: activity_type,
      details: details,
      timestamp: Time.current
    })
  end
end 