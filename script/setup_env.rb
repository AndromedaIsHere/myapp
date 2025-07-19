#!/usr/bin/env ruby

# Setup script for environment variables
# Run this script to create a .env file with your OpenAI API key

require 'fileutils'

# Get the Rails root directory (assuming script is in script/ directory)
rails_root = File.expand_path('..', __dir__)
env_file = File.join(rails_root, '.env')

if File.exist?(env_file)
  puts "⚠️  .env file already exists. Do you want to overwrite it? (y/N)"
  response = STDIN.gets.chomp.downcase
  exit unless response == 'y'
end

puts "🔧 Setting up environment variables..."
puts ""

puts "Please enter your OpenAI API key:"
print "OPENAI_API_KEY: "
api_key = STDIN.gets.chomp.strip

if api_key.empty?
  puts "❌ API key cannot be empty"
  exit 1
end

# Create .env file content
env_content = <<~ENV
  # OpenAI Configuration
  OPENAI_API_KEY=#{api_key}
  
  # Optional OpenAI Configuration
  # OPENAI_API_BASE_URL=https://api.openai.com
  # OPENAI_MODEL=dall-e-3
  # OPENAI_TIMEOUT=30
  # OPENAI_MAX_RETRIES=3
ENV

# Write to .env file
File.write(env_file, env_content)

puts ""
puts "✅ Environment variables configured successfully!"
puts "📁 Created: #{env_file}"
puts ""
puts "🔒 The .env file is already in .gitignore and won't be committed to version control."
puts ""
puts "🚀 You can now restart your Rails server to load the new environment variables." 