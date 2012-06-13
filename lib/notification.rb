class Notification
  # To change this template use File | Settings | File Templates.
  require 'uri'
  require 'net/http'
  require 'ruby-notify-my-android'
  require 'gmail'
  require 'smsglobal'

  def initialize
    @username = ""
    @source_system = ""
    @message = ""
  end

  def notify_group(id, message)
    #define function for notifying all members of a group
  end

  #master notify function
  def notify_user(rule_id, event_id)
    @rule = Rule.find_by_id(rule_id)
    @event = Event.find_by_id(event_id)

    @users = @rule.group.users.all

    @users.each do |user|
      #TODO this is where you would add an event to the user, only keeping 20 at a time for use with the RSS builder
      #check user's timezone
      current_user_time = Time.now.utc + user.timezone.hours

      if (user.business_days == 0) || ((user.business_days == 5) && (current_user_time.wday != 0) && (current_user_time.wday != 6))
        #notifications disabled
      else
        #need to check time
        if (current_user_time.hour >= user.business_hrs_start) && (current_user_time.hour <= user.business_hrs_end)
          case
            when user.use_boxcar_flag == 1
              boxcar_notify(user.boxcar_id, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
            when user.use_email_flag == 1
              mail_notify(user.email, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
            when user.use_im_flag == 1
              im_notify(user.email, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
            when user.use_mobile_ph_flag == 1
              sms_notify(user.mobile_phone_no, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
            when user.use_nma_flag == 1
              nma_notify(user.nma_api_key, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
            when user.use_nmwp_flag == 1
              nma_notify(user.nmwp_api_key, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
          end
          rss_notify(user.rss_address, @rule.source, "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}")
        end
      end
    end
  end

  def notify_group(group_id, message)
    @group = Group.find_by_id(group_id)
    @users = @group.users.all

    @users.each do |user|
      #TODO this is where you would add an event to the user, only keeping 20 at a time for use with the RSS builder
      #check user's timezone
      current_user_time = Time.now.utc + user.timezone.hours

      if (user.business_days == 0) || ((user.business_days == 5) && (current_user_time.wday != 0) && (current_user_time.wday != 6))
        #notifications disabled
      else
        #need to check time
        if (current_user_time.hour >= user.business_hrs_start) && (current_user_time.hour <= user.business_hrs_end)
          case
            when user.use_boxcar_flag == 1
              boxcar_notify(user.boxcar_id, @group.title.to_s, message)
            when user.use_email_flag == 1
              mail_notify(user.email, @group.title.to_s, message)
            when user.use_im_flag == 1
              im_notify(user.email, @group.title.to_s, message)
            when user.use_mobile_ph_flag == 1
              sms_notify(user.mobile_phone_no, @group.title.to_s, message)
            when user.use_nma_flag == 1
              nma_notify(user.nma_api_key, @group.title.to_s, message)
            when user.use_nmwp_flag == 1
              nma_notify(user.nmwp_api_key, @group.title.to_s, message)
          end
          rss_notify(user.rss_address, @group.title.to_s, message)
        end
      end
    end
  end

  #notify by boxcar
  def boxcar_notify(username, source_system, message)
    if username.nil?
      #add username blank, no send
      Rails.logger.warn "#{Time.now.utc} - Failed boxcar_notify - User ID not specified"
    elsif username.respond_to?("each")
      username.each do |username|
        params = {'email' => username, 'notification[from_screen_name]' => source_system, 'notification[message]' => message, 'notification[icon_url]' => 'https://si0.twimg.com/profile_images/1817574149/Twitter_logo.jpg'}
        post = Net::HTTP.post_form(URI.parse(CONFIG[:boxcar_settings][:public_notification_api_uri].to_s), params)
        Rails.logger.info "#{Time.now.utc} - boxcar_notify - #{username} - #{source_system} - #{message}"
      end
    else
      params = {'email' => username, 'notification[from_screen_name]' => source_system, 'notification[message]' => message, 'notification[icon_url]' => 'https://si0.twimg.com/profile_images/1817574149/Twitter_logo.jpg'}
      post = Net::HTTP.post_form(URI.parse(CONFIG[:boxcar_settings][:public_notification_api_uri].to_s), params)
      Rails.logger.info "#{Time.now.utc} - boxcar_notify - #{username} - #{source_system} - #{message}"
    end
  end

  #register by boxcar
  def boxcar_register(username)
    if username.nil?
      #add username blank, no send
      Rails.logger.warn "#{Time.now.utc} - Failed boxcar_register - User ID not specified"
    elsif username.respond_to?("each")
      username.each do |username|
        params = {'email' => username}
        post = Net::HTTP.post_form(URI.parse(CONFIG[:boxcar_settings][:public_notification__subscription_api_uri].to_s), params)
        Rails.logger.info "#{Time.now.utc} - boxcar_register - #{username} - #{source_system} - #{message}"
      end
    else
      params = {'email' => username}
      post = Net::HTTP.post_form(URI.parse(CONFIG[:boxcar_settings][:public_notification__subscription_api_uri].to_s), params)
      Rails.logger.info "#{Time.now.utc} - boxcar_register - #{username} - #{source_system} - #{message}"
    end
  end

  #notify by android
  def nma_notify(api_key, source_system, message)
    NMA.notify do |n|
      n.apikey = api_key
      n.priority = NMA::Priority::HIGH
      n.application = "Ventyx"
      n.event = source_system
      n.description = message
      Rails.logger.info "#{Time.now.utc} - nma_notify - #{api_key} - #{source_system} - #{message}"
    end
  end

  #notify by windows phone
  def nmwp_notify(api_key, source_system, message)
    uri = URI.parse('https://notifymywindowsphone.com/publicapi/notify/')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    params = {'apikey' => api_key, 'application' => "Ventyx", 'event' => source_system, 'description' => message}

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params)
    response = http.request(request)

    Rails.logger.info "#{Time.now.utc} - nmwp_notify - #{api_key} - #{source_system} - #{message}"
  end

  #notify by email
  def mail_notify(username, source_system, message)
  #note - email through gmail is blocked within the corp firewall, works fine otherwise
    Gmail.connect(CONFIG[:gmail_notification_settings][:user_name].to_s, CONFIG[:gmail_notification_settings][:password].to_s) do |gmail|
      gmail.deliver do
        to username
        subject "Notification from #{source_system}"
        text_part do
          body "#{message} \n\nThis email is sent via an external service from an un-monitored inbox. \n\nDo not reply."
        end
        html_part do
          body "<p>#{message}</p><p>This email is sent via an external service from an un-monitored inbox.</p><p>Do not reply.</p>"
        end
        #add_file "/path/to/some_image.jpg"
      end
    end
  end

  #notify by sms(username, source_system, message)
  def sms_notify(username, source_system, message)
    sender = SmsGlobal::Sender.new :user => CONFIG[:sms_global_settings][:user_name].to_s, :password => CONFIG[:sms_global_settings][:password].to_s

    sender.send_text message, username, source_system
  end

  def im_notify(username, source_system, message)
    #TODO figure out what to do about IM
  end

  #notify by rss
  def rss_notify(username, source_system, message)
    #TODO add RSS generator for each individual user
    #requires users to have a record of the last 20 events & rebuild the RSS each time per user
    #code to solve is here - http://techoctave.com/c7/posts/32-create-an-rss-feed-in-rails
  end
end