class AddCompanyIdIndexToUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :company_id
  end
end
