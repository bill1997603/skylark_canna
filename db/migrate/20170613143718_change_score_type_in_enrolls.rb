class ChangeScoreTypeInEnrolls < ActiveRecord::Migration[5.1]
  def change
    change_column :enrolls, :score, :decimal
  end
end
