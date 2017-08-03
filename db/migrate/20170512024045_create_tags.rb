class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :description
      t.references :problem, foreign_key: true

      t.timestamps
    end
  end
end
