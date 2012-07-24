class Group < ActiveRecord::Base
  require 'notification'
  attr_accessible :title, :rule_ids, :user_ids
  has_many :rules
  has_and_belongs_to_many :users
  after_create :new_group_event_milestone

  def notify_group(group_id, message)
    msg = Notification.new
    msg.notify_group(group_id, message)
  end

  def new_group_event_milestone
    #create a system milestone
    @event = Event.new
    @event.call_type = "EVT"
    @event.ctc_id = ""
    @event.cust_no = ""
    @event.cust_region = CONFIG[:core_settings][:app_name].to_s
    @event.description = "New Group Created - #{self.title}"
    @event.entitlement_code = ""
    @event.group_owner = ""
    @event.milestone = "ESC"
    @event.milestone_type = "E"
    @event.other_text = "group creation"
    @event.priority = ""
    @event.source = CONFIG[:core_settings][:app_name].to_s
    @event.start_time = Time.now.utc
    @event.target_time = Time.now.utc
    @event.terminate_flag = "1"
    @event.ticket_id = Digest::SHA1.hexdigest(Time.now.to_s + self.id.to_s)
    @event.time_stamp = Time.now.utc
    @event.save
  end
end
