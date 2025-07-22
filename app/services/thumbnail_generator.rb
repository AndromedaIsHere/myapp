class ThumbnailGenerator
  require "net/http"
  require "uri"
  require "json"
  require "base64"
  require "fileutils"
    def initialize(sketch)
      @sketch = sketch
    end
  
    def generate
        return unless @sketch.image.attached?
        puts "Generating thumbnail for sketch #{@sketch.id}"
        
        # Validate API key is configured
        unless OpenAI::Configuration.api_key.present?
          Rails.logger.error("OpenAI API key not configured")
          @sketch.update!(status: "failed")
          return
        end

        # Create a temporary file from the attached image
        image_path = Rails.root.join("tmp", "sketch_#{@sketch.id}.png")
        File.open(image_path, "wb") do |file|
          file.write(@sketch.image.download)
        end
    
        # Call OpenAI API to generate thumbnail
        response = call_openai_api(image_path)
        puts "Response: #{response}"
    
        if response && response["data"] && response["data"][0] && response["data"][0]["b64_json"]
          # Decode the base64 image
          decoded_image = Base64.decode64(response["data"][0]["b64_json"])
    
          # Store the generated thumbnail
          thumbnail_path = Rails.root.join("tmp", "thumbnail_#{@sketch.id}.png")
          File.open(thumbnail_path, "wb") do |file|
            file.write(decoded_image)
          end
    
          # Save to cloud storage or CDN (simplified for now)
          # In a real app, you might upload this to S3, Cloudinary, etc.
          public_path = Rails.root.join("public", "thumbnails")
          FileUtils.mkdir_p(public_path) unless Dir.exist?(public_path)
          public_thumbnail_path = File.join(public_path, "thumbnail_#{@sketch.id}.png")
          FileUtils.cp(thumbnail_path, public_thumbnail_path)
    
          # Update sketch with the thumbnail URL
          thumbnail_url = "/thumbnails/thumbnail_#{@sketch.id}.png"
          @sketch.update!(
            generated_thumbnail_url: thumbnail_url,
            status: "completed"
          )
    
          # Clean up temporary files
          File.delete(image_path) if File.exist?(image_path)
          File.delete(thumbnail_path) if File.exist?(thumbnail_path)
        else
          @sketch.update!(status: "failed")
        end
      rescue => e
        Rails.logger.error("Thumbnail generation failed: #{e.message}")
        @sketch.update!(status: "failed")
      end
    
      private
    
      def call_openai_api(main_image_path)
        # Use the correct endpoint for image editing
        uri = URI.parse("#{OpenAI::Configuration.api_base_url}/v1/images/edits")
        puts "URI: #{uri}"
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{OpenAI::Configuration.api_key}"
        puts "API Key: #{OpenAI::Configuration.api_key}"
        puts "Request: #{request}"
    
        # Sample additional images that could be used
        # In a real app, these would come from your assets or be uploaded by users
        additional_images = [
          # Rails.root.join("public", "assets", "body-lotion.png"),
          # Rails.root.join("public", "assets", "bath-bomb.png"),
          # Rails.root.join("public", "assets", "incense-kit.png"),
          # Rails.root.join("public", "assets", "soap.png")
        ]
    
        # For image editing, we need to send multipart form data
        form_data = [
          [ "model", "gpt-image-1" ],
          [ "prompt", "Convert this into a youtube thumbnail" ]
        ]
    
        # Add the main image
        form_data << [ "image", File.open(main_image_path), { filename: File.basename(main_image_path), content_type: "image/png" } ]
    
        puts "Form Data: #{form_data}"
        request.set_form(form_data, "multipart/form-data")
    
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, 
                read_timeout: 300, open_timeout: 60) do |http|
          http.request(request)
        end

        puts "Response Code: #{response.code}"
        puts "Response Body: #{response.body}"
        puts "Response Headers: #{response.to_hash}"

        if response.code == "200"
            JSON.parse(response.body)
          else
            Rails.logger.error("OpenAI API error: #{response.body}")
            puts "OpenAI API error: #{response.body}"
            nil
        end
    end
  end