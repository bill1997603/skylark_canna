class AddTrashedToPapers < ActiveRecord::Migration[5.1]
  def change
    add_column :papers, :trashed, :boolean, default: false
  end
end
