class SketchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @sketches = current_user.sketches.order(created_at: :desc)
  end

  def new
    @sketch = current_user.sketches.build
  end

  def create
    @sketch = current_user.sketches.build(sketch_params)
    @sketch.status = "processing"

    # Attach image from base64 data if present
    if params[:sketch][:image_data].present?
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
      ::ThumbnailGenerator.new(@sketch).generate
      redirect_to @sketch, notice: "Sketch was successfully uploaded and processed."
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
    params.require(:sketch).permit(:title, :description)
  end
end