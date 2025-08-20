class SketchesController < ApplicationController
  before_action :authenticate_user!
  require "tempfile"
  require "base64"

  def index
    @sketches = current_user.sketches.order(created_at: :desc)
  end

  def new
    @sketch = current_user.sketches.build
  end

  def create
    # Build sketch with permitted attributes except canvas_data (which isn't a db column)
    @sketch = current_user.sketches.build(sketch_params)
    @sketch.status = "processing"

    # Log the prompt being saved
    if @sketch.prompt.present?
      Rails.logger.info("Saving sketch with prompt: #{@sketch.prompt}")
    else
      Rails.logger.info("Saving sketch without a prompt")
    end

    # Handle image attachment with priority: File upload > Canvas data > Legacy image data
    if sketch_params[:image].present?
      # Priority 1: Handle file upload
      @sketch.image.attach(sketch_params[:image])
      Rails.logger.info("Sketch created from uploaded file: #{sketch_params[:image].original_filename}")
    elsif params[:sketch][:canvas_data].present?
      # Priority 2: Handle canvas data
      data_uri = params[:sketch][:canvas_data]
      encoded_image = data_uri.split(",")[1]
      decoded_image = Base64.decode64(encoded_image)

      # Create a temp file with the decoded image data
      temp_file = Tempfile.new([ "sketch", ".png" ])
      temp_file.binmode
      temp_file.write(decoded_image)
      temp_file.rewind

      # Attach the image to the sketch
      @sketch.image.attach(
        io: temp_file,
        filename: "sketch-#{Time.current.to_i}.png",
        content_type: "image/png"
      )
      Rails.logger.info("Sketch created from canvas drawing")
    elsif params[:sketch][:image_data].present?
      # Priority 3: Fallback for legacy direct image data
      image_data = params[:sketch][:image_data]
      content_type = "image/png"
      # Remove the data URL prefix if present
      if image_data =~ /^data:(.*?);base64,/
        image_data = image_data.split(',')[1]
      end
      decoded_data = Base64.decode64(image_data)
      @sketch.image.attach(io: StringIO.new(decoded_data), filename: "sketch.png", content_type: content_type)
      Rails.logger.info("Sketch created from legacy image data")
    end

    if @sketch.save
      # Enqueue background job for thumbnail generation
      ThumbnailWorker.perform_async(@sketch.id)
      redirect_to @sketch, notice: "Sketch was successfully created. Thumbnail generation is in progress."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_thumbnail
    @sketch = Sketch.find(params[:id])
    if @sketch.image.attached?
      ThumbnailGenerator.new(@sketch).generate
      redirect_to @sketch, notice: "Thumbnail generated!"
    else
      redirect_to @sketch, alert: "No image attached to generate thumbnail."
    end
  end

  def show
    @sketch = current_user.sketches.find(params[:id])
  end

  private

  def sketch_params
    params.require(:sketch).permit(:title, :description, :prompt, :image)
  end
end