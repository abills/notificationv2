class Record < ActiveRecord::Base
  attr_accessible :email, :message, :source, :rule_id_ref, :boxcar_notify, :nma_notify, :nmwp_notify, :mobile_ph_notify, :im_notify, :email_notify, :salesforce_notify
  belongs_to :user
end


