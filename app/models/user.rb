class User < ActiveRecord::Base
  require 'notification'

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
    msg = Notification.new

    #if boxcar changed do registration
    if self.boxcar_id_changed? and not self.boxcar_id.empty?
      #do changes
      msg.boxcar_register(self.boxcar_id)
    end

    #check each "enabled" value against changed & notify if value has been changed as a test, ignore time of day
    case
      when self.use_boxcar_flag == 1
        if (self.use_boxcar_flag_changed? and not self.boxcar_id.empty?) or (self.boxcar_id_changed?)
          msg.boxcar_notify(self.boxcar_id, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
      when self.use_email_flag == 1
        if (self.use_email_flag_changed? and not self.email.empty?) or (self.email_changed?)
          msg.mail_notify(self.email, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
      when self.use_im_flag == 1
        if (self.use_im_flag_changed? and not self.email.empty?) or (self.email_changed?)
          msg.im_notify(self.email, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
      when self.use_mobile_ph_flag == 1
        if (self.use_mobile_ph_flag_changed? and not self.mobile_phone_no.empty?) or (self.mobile_phone_no_changed?)
          msg.sms_notify(self.mobile_phone_no, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
      when self.use_nma_flag == 1
        if (self.use_nma_flag_changed? and not self.nma_api_key.empty?) or (self.nma_api_key_changed?)
          msg.nma_notify(self.nma_api_key, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
      when self.use_nmwp_flag == 1
        if (self.use_nmwp_flag_changed? and not self.nmwp_api_key.empty?) or (self.nmwp_api_key_changed?)
          msg.nma_notify(self.nmwp_api_key, CONFIG[:core_settings][:app_name].to_s, "Test Message, notification settings changed")
        end
    end
  end
end
