class Group < ActiveRecord::Base
  attr_accessible :title, :rule_ids, :user_ids
  has_many :rules
  has_and_belongs_to_many :users
end
