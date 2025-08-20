#!/usr/bin/env ruby
require_relative 'config/environment'

# Debug script for testing thumbnail generation
# Run this with: rails runner debug_thumbnail_generator.rb
# This script creates a test sketch and generates a thumbnail for it

puts "Creating a test sketch..."
sketch = Sketch.create!(
  status: "processing", 
  prompt: "Create a thumbnail that shows a tech gadget review with bright colors"
)

# Attach a test image if one exists
test_image_path = Rails.root.join('public', 'test_sketch.png')
if File.exist?(test_image_path)
  sketch.image.attach(
    io: File.open(test_image_path),
    filename: 'test_sketch.png',
    content_type: 'image/png'
  )
  puts "Test image attached"
else
  puts "No test image found at #{test_image_path}"
  puts "The thumbnail generator will still run, but without an actual image."
end

puts "Sketch prompt: #{sketch.prompt}"
puts "Running thumbnail generator..."
generator = ThumbnailGenerator.new(sketch)
generator.generate

puts "Thumbnail generated!"
puts "Status: #{sketch.status}"
puts "Prompt used: #{sketch.prompt}"

if sketch.generated_thumbnail.attached?
  puts "Generated thumbnail is attached"
else
  puts "No generated thumbnail found"
end