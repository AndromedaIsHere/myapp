class Sketch < ApplicationRecord
  belongs_to :user, optional: true # (optional: true for the first migration)
  has_one_attached :image
  has_one_attached :generated_thumbnail
  
  # Custom validations for file attachments
  validate :image_must_be_attached
  validate :image_must_be_valid_format
  validate :generated_thumbnail_must_be_valid_format, if: :generated_thumbnail_attached?
  
  # Image variants for different use cases
  def thumbnail
    return nil unless image.attached?
    begin
      image.variant(resize_to_limit: [300, 300]).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("Image file not found for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  def medium
    return nil unless image.attached?
    begin
      image.variant(resize_to_limit: [600, 600]).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("Image file not found for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  def preview
    return nil unless image.attached?
    begin
      image.variant(resize_to_limit: [150, 150]).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("Image file not found for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  # Fallback thumbnail using image processing if OpenAI generation fails
  def fallback_thumbnail
    return nil unless image.attached?
    begin
      image.variant(resize_to_limit: [300, 300], format: :png).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("Image file not found for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  # Get the best available thumbnail (AI-generated or fallback)
  def best_thumbnail
    begin
      if generated_thumbnail.attached?
        generated_thumbnail
      elsif image.attached?
        fallback_thumbnail
      else
        nil
      end
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("File not found when getting best thumbnail for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  # Optimized image for API calls (performance optimization)
  def optimized_image
    return nil unless image.attached?
    
    begin
      image.variant(
        resize_to_limit: [2048, 2048],  # Limit size for API calls
        format: :png,
        quality: 90
      ).processed
    rescue ActiveStorage::FileNotFoundError => e
      Rails.logger.error("Image file not found for sketch #{id}: #{e.message}")
      nil
    end
  end
  
  private
  
  # Custom validation methods
  def image_must_be_attached
    unless image.attached?
      errors.add(:image, "must be attached")
    end
  end
  
  def image_must_be_valid_format
    return unless image.attached?
    
    unless image.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:image, "must be a PNG, JPG, or JPEG file")
    end
  end
  
  def generated_thumbnail_attached?
    generated_thumbnail.attached?
  end
  
  def generated_thumbnail_must_be_valid_format
    return unless generated_thumbnail.attached?
    
    unless generated_thumbnail.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add(:generated_thumbnail, "must be a PNG, JPG, or JPEG file")
    end
    
    if generated_thumbnail.byte_size > 5.megabytes
      errors.add(:generated_thumbnail, "must be smaller than 5MB")
    end
  end
end
