#!/usr/bin/env ruby
require_relative 'config/environment'

# This script creates a test sketch and generates a thumbnail for it

unless ENV["OPENAI_API_KEY"]
  puts "ERROR: Please set the OPENAI_API_KEY environment variable."
  exit 1
end

puts "Creating a test sketch..."
sketch = Sketch.create!(status: "processing")

# Attach the new test image if it exists
image_path = Rails.root.join('public', 'thumbnail.png')
if File.exist?(image_path)
  puts "Attaching test image from #{image_path}..."
  # If Sketch has ActiveStorage, attach here. Otherwise, just log.
  if sketch.respond_to?(:image) && sketch.image.respond_to?(:attach)
    sketch.image.attach(io: File.open(image_path), filename: 'thumbnail.png')
  end
else
  puts "Warning: No test image found at #{image_path}"
  puts "The thumbnail generator will still run, but without an actual image."
end

puts "Running thumbnail generator..."
generator = ThumbnailGenerator.new(sketch)
generator.generate

puts "Thumbnail generated!"
puts "Status: #{sketch.status}"
puts "Generated thumbnail attached: #{sketch.generated_thumbnail.attached?}"
if sketch.generated_thumbnail.attached?
  puts "Thumbnail filename: #{sketch.generated_thumbnail.filename}"
  puts "Thumbnail content type: #{sketch.generated_thumbnail.content_type}"
end