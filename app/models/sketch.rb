class Sketch < ApplicationRecord
  belongs_to :user, optional: true # (optional: true for the first migration)
  has_one_attached :image
  has_one_attached :generated_thumbnail
  
  # Image variants for different use cases
  def thumbnail
    image.variant(resize_to_limit: [300, 300]).processed
  end
  
  def medium
    image.variant(resize_to_limit: [600, 600]).processed
  end
  
  def preview
    image.variant(resize_to_limit: [150, 150]).processed
  end
  
  # Fallback thumbnail using image processing if OpenAI generation fails
  def fallback_thumbnail
    return nil unless image.attached?
    image.variant(resize_to_limit: [300, 300], format: :png).processed
  end
  
  # Get the best available thumbnail (AI-generated or fallback)
  def best_thumbnail
    if generated_thumbnail.attached?
      generated_thumbnail
    elsif generated_thumbnail_url.present?
      generated_thumbnail_url
    elsif image.attached?
      fallback_thumbnail
    else
      nil
    end
  end
end
