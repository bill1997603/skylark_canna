class CreateJoinTableProblemTag < ActiveRecord::Migration[5.1]
  def change
    create_join_table :problems, :tags do |t|
      t.index [:problem_id, :tag_id]
    end
  end
end
