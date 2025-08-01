class Sketch < ApplicationRecord
  belongs_to :user, optional: true # (optional: true for the first migration)
  has_one_attached :image
  has_one_attached :generated_thumbnail
  
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
      elsif generated_thumbnail_url.present?
        generated_thumbnail_url
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
end
