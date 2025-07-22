class EnforceUserOnSketches < ActiveRecord::Migration[7.0]
  def up
    if Sketch.where(user_id: nil).exists?
      user = User.first
      if user.nil?
        puts "Warning: No users found. Cannot assign sketches to a user."
        return
      end
      Sketch.where(user_id: nil).update_all(user_id: user.id)
    end
    change_column_null :sketches, :user_id, false
  end

  def down
    change_column_null :sketches, :user_id, true
  end
end 