class Event < ActiveRecord::Base
  attr_accessible :call_type, :ctc_id, :cust_no, :cust_region, :description, :entitlement_code, :group_owner, :milestone, :milestone_type, :other_text, :priority, :source, :terminate_flag, :ticket_id, :target_time, :time_stamp, :start_time
  has_and_belongs_to_many :rules

  after_create :add_event

  def add_event
    RULES_ENG.assert_event(self)
  end
end
