class ThumbnailWorker
  include Sidekiq::Worker
  sidekiq_options queue: :thumbnails, retry: 3

  def perform(sketch_id)
    Rails.logger.info("ThumbnailWorker: Starting job for sketch #{sketch_id}")
    
    sketch = Sketch.find_by(id: sketch_id)
    
    unless sketch
      Rails.logger.error("ThumbnailWorker: Sketch #{sketch_id} not found")
      return
    end
    
    unless sketch.image.attached?
      Rails.logger.error("ThumbnailWorker: No image attached for sketch #{sketch_id}")
      sketch.update_column(:status, "failed")
      return
    end

    Rails.logger.info("ThumbnailWorker: Processing sketch #{sketch_id} (user: #{sketch.user_id})")
    
    start_time = Time.current
    generator = ThumbnailGenerator.new(sketch)
    success = generator.generate
    duration = Time.current - start_time
    
    if success
      Rails.logger.info("ThumbnailWorker: Successfully completed thumbnail generation for sketch #{sketch_id} in #{duration.round(2)}s")
    else
      Rails.logger.error("ThumbnailWorker: Failed to generate thumbnail for sketch #{sketch_id} after #{duration.round(2)}s")
      # The generator already set the status to failed, so we don't need to do it again
    end
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("ThumbnailWorker: Sketch #{sketch_id} not found: #{e.message}")
  rescue => e
    Rails.logger.error("ThumbnailWorker: Unexpected error for sketch #{sketch_id}: #{e.class.name} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n")) if Rails.env.development?
    
    # Update status if we have a sketch object
    sketch&.update_column(:status, "failed")
    
    # Re-raise to trigger Sidekiq retry mechanism
    raise e
  end
end 