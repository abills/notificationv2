class Event < ActiveRecord::Base
  attr_accessible :call_type, :ctc_id, :cust_no, :cust_region, :description, :entitlement_code, :group_owner, :milestone, :milestone_type, :other_text, :priority, :source, :terminate_flag, :ticket_id, :time_stamp, :triggered_rules
  serialize :triggered_rules,Array
  has_and_belongs_to_many :rules
end
