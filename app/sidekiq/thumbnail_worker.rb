class ThumbnailWorker
  include Sidekiq::Worker
  sidekiq_options queue: :thumbnails, retry: 3

  def perform(sketch_id)
    sketch = Sketch.find_by(id: sketch_id)
    puts "Sketch in ThumbnailWorker: #{sketch.inspect}"
    return unless sketch && sketch.image.attached?

    generator = ThumbnailGenerator.new(sketch)
    generator.generate
  end
end 