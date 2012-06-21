class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :source
      t.string :message
      t.belongs_to :user

      t.timestamps
    end

    create_table(:users_records, :id => false) do |t|
      t.references :user
      t.references :record
    end

    add_index(:users_records, [ :user_id, :record_id ])
  end
end
