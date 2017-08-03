class DropJoinTablePaperProblem < ActiveRecord::Migration[5.1]
  def change
    drop_table :papers_problems
  end
end
