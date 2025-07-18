class SketchesController < ApplicationController
  def new
    @sketch = Sketch.new
  end

  def create
    @sketch = Sketch.new(sketch_params)
    @sketch.status = "processing"

    if @sketch.save
      # Generate the thumbnail
      ::ThumbnailGenerator.new(@sketch).generate
      
      redirect_to @sketch, notice: "Sketch was successfully uploaded and processed."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @sketch = Sketch.find(params[:id])
  end

  private

  def sketch_params
    params.require(:sketch).permit(:image)
  end
end