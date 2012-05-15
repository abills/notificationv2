class User < ActiveRecord::Base
	rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :confirmed_at, :group_ids, :country_iso, :use_email_flag, :use_boxcar_flag, :use_mobile_ph_flag, :use_im_flag, :boxcar_id, :mobile_phone_no, :business_days, :business_hrs_start, :business_hrs_end
  has_and_belongs_to_many :groups
end
