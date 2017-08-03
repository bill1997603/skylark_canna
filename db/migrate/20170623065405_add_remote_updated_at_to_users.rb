class AddRemoteUpdatedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :remote_updated_at, :timestamp
  end
end
