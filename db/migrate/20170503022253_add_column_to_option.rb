class AddColumnToOption < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :problem_id, :integer
  end
end
