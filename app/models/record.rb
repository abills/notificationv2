class Record < ActiveRecord::Base
  attr_accessible :email, :message, :source
  belongs_to :user
end
