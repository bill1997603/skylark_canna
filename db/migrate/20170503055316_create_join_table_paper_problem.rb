class CreateJoinTablePaperProblem < ActiveRecord::Migration[5.1]
  def change
    create_join_table :papers, :problems do |t|
      t.index [:paper_id, :problem_id]
    end
  end
end
