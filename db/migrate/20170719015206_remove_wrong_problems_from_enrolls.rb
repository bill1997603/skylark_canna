class RemoveWrongProblemsFromEnrolls < ActiveRecord::Migration[5.1]
  def change
    remove_column :enrolls, :wrong_problems, :string
  end
end
