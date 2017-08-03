class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.string :label
      t.text :description
      t.boolean :right, default: false

      t.timestamps
    end
  end
end
