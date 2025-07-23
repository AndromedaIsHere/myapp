class ApplicationController < ActionController::Base
  # Add Devise helper to make authenticate_user! available
  before_action :authenticate_user!
  
  # Add security headers
  before_action :set_security_headers
  
  private
  
  def set_security_headers
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
  end
end
