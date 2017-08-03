class CreateProblems < ActiveRecord::Migration[5.1]
  def change
    create_table :problems do |t|
      t.text :description
      t.integer :form, default: 1

      t.timestamps
    end
  end
end
