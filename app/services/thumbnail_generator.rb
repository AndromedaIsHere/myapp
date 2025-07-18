class ThumbnailGenerator
    def initialize(sketch)
      @sketch = sketch
    end
  
    def generate
      # Fake generation for now
      dummy_thumbnail_url = "https://placehold.co/1280x720"
  
      @sketch.update!(
        generated_thumbnail_url: dummy_thumbnail_url,
        status: "completed"
      )
    end
  end