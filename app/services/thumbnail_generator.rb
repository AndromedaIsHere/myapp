class ThumbnailGenerator
  require "net/http"
  require "uri"
  require "json"
  require "base64"
  require "fileutils"
  require "stringio"
    def initialize(sketch)
      @sketch = sketch
    end
  
    def generate
        return unless @sketch&.image&.attached?
        
        Rails.logger.info("Starting thumbnail generation for sketch #{@sketch.id}")
        image_path = nil
        
        # Validate API key is configured
        unless OpenAI::Configuration.api_key.present?
          Rails.logger.error("OpenAI API key not configured for sketch #{@sketch.id}")
          update_status("failed")
          return false
        end

        begin
          ActiveRecord::Base.transaction do
            # Update status to processing
            @sketch.update!(status: "processing")
            
            # Create a temporary file from the attached image
            image_path = Rails.root.join("tmp", "sketch_#{@sketch.id}_#{Time.current.to_i}.png")
            
            File.open(image_path, "wb") do |file|
              file.write(@sketch.image.download)
            end
            
            Rails.logger.info("Downloaded image to temporary file for sketch #{@sketch.id}")
        
            # Call OpenAI API to generate thumbnail
            response = call_openai_api(image_path)
        
            if successful_generation?(response)
              process_successful_generation(response)
              Rails.logger.info("Successfully generated thumbnail for sketch #{@sketch.id}")
              return true
            else
              Rails.logger.warn("OpenAI API did not return expected data for sketch #{@sketch.id}")
              update_status("failed")
              return false
            end
          end
        rescue ActiveStorage::FileNotFoundError => e
          Rails.logger.error("Image file not found for sketch #{@sketch.id}: #{e.message}")
          update_status("failed")
          return false
        rescue Net::TimeoutError => e
          Rails.logger.error("OpenAI API timeout for sketch #{@sketch.id}: #{e.message}")
          update_status("failed")
          return false
        rescue JSON::ParserError => e
          Rails.logger.error("Invalid JSON response from OpenAI API for sketch #{@sketch.id}: #{e.message}")
          update_status("failed")
          return false
        rescue => e
          Rails.logger.error("Thumbnail generation failed for sketch #{@sketch.id}: #{e.class.name} - #{e.message}")
          Rails.logger.error(e.backtrace.join("\n")) if Rails.env.development?
          update_status("failed")
          return false
        ensure
          # Always clean up temporary files
          if image_path && File.exist?(image_path)
            File.delete(image_path)
            Rails.logger.debug("Cleaned up temporary file for sketch #{@sketch.id}")
          end
        end
      end
    
      private
      
      def update_status(status)
        @sketch.update_column(:status, status)
      rescue => e
        Rails.logger.error("Failed to update sketch #{@sketch.id} status to #{status}: #{e.message}")
      end
      
      def successful_generation?(response)
        response && 
        response["data"] && 
        response["data"][0] && 
        response["data"][0]["b64_json"].present?
      end
      
      def process_successful_generation(response)
        # Decode the base64 image
        decoded_image = Base64.decode64(response["data"][0]["b64_json"])

        # Store the generated thumbnail using ActiveStorage
        @sketch.generated_thumbnail.attach(
          io: StringIO.new(decoded_image),
          filename: "thumbnail_#{@sketch.id}.png",
          content_type: "image/png"
        )

        # Update sketch status
        @sketch.update!(status: "completed")
      end
    
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
          [ "prompt", "Generate a thumbnail for a YouTube video based on the uploaded image." ]
        ]
    
        # Add the main image
        form_data << [ "image", File.open(main_image_path), { filename: File.basename(main_image_path), content_type: "image/png" } ]
    
        puts "Form Data: #{form_data}"
        request.set_form(form_data, "multipart/form-data")

        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true
        http.open_timeout = 60 # Increase open timeout to 60 seconds
        http.read_timeout = 300 # Increase read timeout to 300 seconds (5 minutes)
        response = http.request(request)

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