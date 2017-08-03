class AddTrashedToProblem < ActiveRecord::Migration[5.1]
  def change
    add_column :problems, :trashed, :boolean, default: false
  end
end
