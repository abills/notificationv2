class AddMissingIndexes < ActiveRecord::Migration
  def up
    add_index :rules, :group_id
    add_index :users, [:invited_by_id, :invited_by_type]
    add_index :records, :user_id
  end

  def down
    remove_index :rules, :group_id
    remove_index :users, :column => [:invited_by_id, :invited_by_type]
    remove_index :records, :user_id
  end
end