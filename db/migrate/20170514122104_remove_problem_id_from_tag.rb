class RemoveProblemIdFromTag < ActiveRecord::Migration[5.1]
  def change
    remove_reference :tags, :problem, foreign_key: true
  end
end
