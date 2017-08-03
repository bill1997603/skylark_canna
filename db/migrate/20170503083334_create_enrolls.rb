class CreateEnrolls < ActiveRecord::Migration[5.1]
  def change
    create_table :enrolls do |t|
      t.integer :user_id
      t.integer :paper_id
      t.column :hand_in_time, 'timestamp with time zone'
      t.integer :score

      t.timestamps
    end
  end
end
