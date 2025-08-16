class RemoveGeneratedThumbnailUrlFromSketches < ActiveRecord::Migration[8.0]
  def change
    remove_column :sketches, :generated_thumbnail_url, :string
  end
end
