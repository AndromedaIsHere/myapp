# OpenAI API Configuration
# This file centralizes all OpenAI-related configuration

module OpenAI
  class Configuration
    class << self
      def api_key
        # Try credentials first (for production), then environment variable
        Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY']
      end

      def api_base_url
        ENV['OPENAI_API_BASE_URL'] || 'https://api.openai.com'
      end

      def model
        ENV['OPENAI_MODEL'] || 'dall-e-3'
      end

      def timeout
        (ENV['OPENAI_TIMEOUT'] || 30).to_i
      end

      def max_retries
        (ENV['OPENAI_MAX_RETRIES'] || 3).to_i
      end
    end
  end
end 