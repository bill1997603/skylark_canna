class AddRemoteUpdatedAtToOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :remote_updated_at, :timestamp
  end
end
