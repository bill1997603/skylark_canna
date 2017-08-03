class AddWrongProblemsToEnrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :enrolls, :wrong_problems, :string
  end
end
