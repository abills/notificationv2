class Group < ActiveRecord::Base
  require 'notification'
  attr_accessible :title, :rule_ids, :user_ids
  has_many :rules
  has_and_belongs_to_many :users

  def notify_group(id, message)
    #TODO when the group controller is figured out add notify for each user in the group here
    msg = Notification.new
    msg.notify_group(id, message)
  end
end
