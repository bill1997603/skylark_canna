class CreatePapers < ActiveRecord::Migration[5.1]
  def change
    create_table :papers do |t|
      t.integer :scale, default: 1
      t.column :deadline, 'timestamp with time zone'

      t.timestamps
    end
  end
end
