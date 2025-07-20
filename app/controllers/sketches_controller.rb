class SketchesController < ApplicationController
  def new
    @sketch = Sketch.new
  end

  def create
    @sketch = Sketch.new(sketch_params)
    if params[:sketch][:image_data].present?
      data = params[:sketch][:image_data]
      content_type = data[%r{data:(.*?);}, 1]
      encoded_image = data.sub(%r{^data:.*;base64,}, '')
      decoded_image = Base64.decode64(encoded_image)
      @sketch.image.attach(
        io: StringIO.new(decoded_image),
        filename: "sketch.png",
        content_type: content_type
      )
    end
    if @sketch.save
      # Generate thumbnail after saving and attaching image
      ThumbnailGenerator.new(@sketch).generate if @sketch.image.attached?
      redirect_to @sketch, notice: "Sketch was successfully created."
    else
      render :new
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
    @sketch = Sketch.find(params[:id])
  end

  private

  def sketch_params
    params.require(:sketch).permit(:title, :description) # remove :image_data
  end
end