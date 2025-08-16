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
    @sketch = current_user.sketches.build
    @sketch.status = "processing"

    # Handle canvas data if provided
    if params[:sketch][:canvas_data].present?
      # Extract the base64 data from the data URL
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
    elsif params[:sketch][:image_data].present?
      # Fallback for direct image data
      image_data = params[:sketch][:image_data]
      content_type = "image/png"
      # Remove the data URL prefix if present
      if image_data =~ /^data:(.*?);base64,/
        image_data = image_data.split(',')[1]
      end
      decoded_data = Base64.decode64(image_data)
      @sketch.image.attach(io: StringIO.new(decoded_data), filename: "sketch.png", content_type: content_type)
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
    params.require(:sketch).permit(:title, :description, :canvas_data)
  end
end