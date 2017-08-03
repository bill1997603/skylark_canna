class AddCodeToPapers < ActiveRecord::Migration[5.1]
  def change
    add_column :papers, :code, :string
  end
end
