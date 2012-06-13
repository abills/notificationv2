class User < ActiveRecord::Base
	rolify
  # Include default devise modules. Others available are:
  # :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :confirmed_at, :group_ids, :country_iso, :use_email_flag, :use_boxcar_flag, :use_mobile_ph_flag, :use_im_flag, :boxcar_id, :mobile_phone_no, :business_days, :business_hrs_start, :business_hrs_end, :timezone, :use_nma_flag, :nma_api_key, :use_nmwp_flag, :nmwp_api_key, :authentication_token
  has_and_belongs_to_many :groups

  unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
    after_save :test_notification_settings
  end

  def test_notification_settings
    #create a notification object
    #check each "enabled" value against changed
    #send a notification
    #if boxcar is "changed" then register
  end
end
