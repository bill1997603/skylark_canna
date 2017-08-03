class RemoveLabelFromOptions < ActiveRecord::Migration[5.1]
  def change
    remove_column :options, :label, :string
  end
end
