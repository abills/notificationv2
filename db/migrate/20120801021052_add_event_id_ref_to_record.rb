class AddEventIdRefToRecord < ActiveRecord::Migration
  def change
    add_column :records, :event_id_ref, :integer
  end
end
