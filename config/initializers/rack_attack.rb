class Rack::Attack
  # Rate limiting for login attempts
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/users/sign_in' && req.post?
  end

  # Rate limiting for API endpoints
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Rate limiting for sketch uploads
  throttle('sketches/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/sketches' && req.post?
  end

  # Block suspicious requests
  blocklist('block suspicious user agents') do |req|
    req.user_agent && (
      req.user_agent.include?('bot') ||
      req.user_agent.include?('crawler') ||
      req.user_agent.include?('spider')
    )
  end

  # Log blocked requests
  blocklist_response = lambda do |env|
    [ 403, { 'Content-Type' => 'text/plain' }, ['Forbidden'] ]
  end

  # Set the response for both blocklisted and throttled requests
  self.blocklisted_response = blocklist_response
  self.throttled_response = blocklist_response
end 