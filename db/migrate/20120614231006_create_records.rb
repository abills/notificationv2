class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :source
      t.string :message
      t.integer :rule_id_ref
      t.integer :boxcar_notify
      t.integer :nma_notify
      t.integer :nmwp_notify
      t.integer :mobile_ph_notify
      t.integer :im_notify
      t.integer :email_notify
      t.integer :salesforce_notify
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
