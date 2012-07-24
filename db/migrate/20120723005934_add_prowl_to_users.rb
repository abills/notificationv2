class AddProwlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prowl_api_key, :string
    add_column :users, :use_prowl_flag, :integer
    add_column :records, :prowl_notify, :integer
  end
end
