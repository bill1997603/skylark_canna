class AddProblemIdIndexToOptions < ActiveRecord::Migration[5.1]
  def change
    add_index :options, :problem_id
  end
end
