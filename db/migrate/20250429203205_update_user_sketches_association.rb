class UpdateUserSketchesAssociation < ActiveRecord::Migration[7.0]
  def change
    add_reference :sketches, :user, foreign_key: true, null: true
  end
end 