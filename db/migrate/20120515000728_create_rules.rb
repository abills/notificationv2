class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :title
      t.belongs_to :group
      t.string :sql_query
      t.string :syntax_msg
      t.string :group_owner
      t.string :source
      t.string :cust_no
      t.integer :priority
      t.string :entitlement_code
      t.string :call_type
      t.string :other_text_operator
      t.string :other_text_value
      t.string :ctc_id_operator
      t.string :ctc_id_value
      t.string :milestone1_operator
      t.string :milestone1_value
      t.float :milestone1_time_value
      t.string :milestone1_time_value_denomination
      t.string :milestone2_operator
      t.string :milestone2_value
      t.float :milestone2_time_value
      t.string :milestone2_time_value_denomination
      t.string :target_time_operator
      t.float :target_time_value
      t.string :target_time_value_denomination

      t.timestamps
    end
  end
end
