class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :milestone
      t.string :ticket_id
      t.string :call_type
      t.string :source
      t.datetime :time_stamp
      t.string :cust_no
      t.string :cust_region
      t.string :other_text
      t.integer :priority
      t.string :group_owner
      t.string :ctc_id
      t.string :entitlement_code
      t.string :description
      t.string :milestone_type
      t.integer :terminate_flag

      t.timestamps
    end
  end
end
