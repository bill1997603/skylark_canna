class AddIndexToEnrolls < ActiveRecord::Migration[5.1]
  def change
    add_index :enrolls, :user_id
    add_index :enrolls, :paper_id
  end
end
