class Group < ActiveRecord::Base
  require 'notification'
  attr_accessible :title, :rule_ids, :user_ids
  has_many :rules
  has_and_belongs_to_many :users

  def notify_group(group_id, message)
    msg = Notification.new
    msg.notify_group(group_id, message)
  end
end
