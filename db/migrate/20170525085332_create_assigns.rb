class CreateAssigns < ActiveRecord::Migration[5.1]
  def change
    create_table :assigns do |t|
      t.integer :problem_id
      t.integer :paper_id
      t.decimal :problem_score, default: 5

      t.timestamps
    end

    add_index :assigns, :problem_id
    add_index :assigns, :paper_id
  end
end
