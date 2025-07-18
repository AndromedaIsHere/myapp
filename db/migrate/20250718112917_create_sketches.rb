class CreateSketches < ActiveRecord::Migration[8.0]
  def change
    create_table :sketches do |t|
      t.string :generated_thumbnail_url
      t.string :status

      t.timestamps
    end
  end
end
