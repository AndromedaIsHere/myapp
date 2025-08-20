class AddPromptToSketches < ActiveRecord::Migration[8.0]
  def change
    add_column :sketches, :prompt, :text
  end
end
