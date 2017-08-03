class AddChosenListToEnrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :enrolls, :chosen_list, :string, array: true, default: []
  end
end
