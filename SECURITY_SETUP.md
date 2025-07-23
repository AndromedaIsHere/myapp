# Security Setup Guide

This application has been configured with comprehensive security features. Follow these steps to complete the setup:

## Environment Variables

Add the following environment variables to your `.env` file or deployment configuration:

```bash
# Sentry Configuration
SENTRY_DSN=your_sentry_dsn_here

# Security
RACK_ATTACK_ENABLED=true

# Redis (for Sidekiq and rate limiting)
REDIS_URL=redis://localhost:6379/1
```

## Sentry Setup

1. Create a Sentry account at https://sentry.io
2. Create a new project for your Rails application
3. Get your DSN from the project settings
4. Add the DSN to your environment variables

## Security Features Implemented

### 1. Content Security Policy (CSP)
- Enabled in report-only mode initially
- Configured to allow only secure sources
- Session nonces for inline scripts and styles

### 2. Rate Limiting (Rack Attack)
- Login attempts: 5 per 20 seconds per IP
- API requests: 100 per minute per IP
- Sketch uploads: 10 per minute per IP
- Blocks suspicious user agents

### 3. Security Headers
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

### 4. Parameter Filtering
- Filters sensitive data from logs
- Includes passwords, tokens, API keys, etc.

### 5. Devise Security
- Maximum 5 login attempts before lockout
- 30-minute lockout period
- Minimum 8-character passwords
- Secure sign-out via DELETE method

### 6. Error Tracking
- Sentry integration for error monitoring
- Performance monitoring enabled
- Sensitive data filtering

## Testing Security Features

Run these commands to test your security setup:

```bash
# Security scans
bin/brakeman --no-pager
bin/importmap audit
bin/rubocop -f github

# Test rate limiting
curl -X POST http://localhost:3000/users/sign_in -d "user[email]=test@example.com&user[password]=password"
```

## Monitoring

- Check Sentry dashboard for errors and performance issues
- Monitor rate limiting logs in production
- Review CSP violation reports (when enabled)

## Production Deployment

1. Set `SENTRY_DSN` in your production environment
2. Enable `RACK_ATTACK_ENABLED=true`
3. Configure proper Redis URL
4. Set `SENTRY_ENVIRONMENT=production`

## Security Best Practices

1. Keep dependencies updated
2. Monitor Sentry for security-related errors
3. Review rate limiting logs regularly
4. Consider enabling CSP enforcement after testing
5. Use HTTPS in production
6. Regularly audit user permissions 