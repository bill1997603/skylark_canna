class CreateJoinTableUserOrganization < ActiveRecord::Migration[5.1]
  def change
    create_join_table :users, :organizations do |t|
      t.index [:user_id, :organization_id]
    end
  end
end
