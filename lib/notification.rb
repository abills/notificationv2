class Notification
  # To change this template use File | Settings | File Templates.
  require 'uri'
  require 'net/http'
  require 'ruby-notify-my-android'
  require 'gmail'
  require 'smsglobal'
  require 'builder'
  require 'prowly'

  def initialize
    @username = ""
    @source_system = ""
    @message = ""
  end

  #master notify function
  def notify_user(rule_id, event_id)
    @rule = Rule.find_by_id(rule_id)
    @users = @rule.group.users.all
    @event = Event.find_by_id(event_id)

    if @event.nil?
      @event.cust_region = "Unknown"
      @event.ticket_id = "Not Available"
      @event.description = "Not Available"
    end

    if @users.nil?
      #do nothing
      Rails.logger.info "#{Time.now.utc} - Nil Users to notify in #{@group.title.to_s}"
    else
      @users.each do |user|
        #add notification to user feed
        Rails.logger.info "#{Time.now.utc} - User to Notify #{user.name.to_s}"
        @record = Record.new
        @record.rule_id_ref = rule_id
        @record.event_id_ref = event_id
        @record.source = @rule.source
        #for heartbeat & system rules where source is not defined
        if @record.source.nil?
          @record.source == CONFIG[:core_settings][:app_name]
        end

        @record.message = "#{@rule.syntax_msg} | #{@event.cust_region} | #{@event.ticket_id} - #{@event.description}"
        #check user's timezone
        current_user_time = Time.now.utc + user.timezone.hours

        if (user.business_days == 0) or ((user.business_days == 5) and ((current_user_time.wday == 0) or (current_user_time.wday == 6)))
          #notifications disabled
        else
          #need to check time
          if (current_user_time.hour >= user.business_hrs_start) && (current_user_time.hour < user.business_hrs_end)
            if user.use_boxcar_flag == 1
              Thread.new do
                boxcar_notify(user.boxcar_id, @record.source.to_s, @record.message.to_s)
              end
              @record.boxcar_notify = user.use_boxcar_flag
            end
            if user.use_email_flag == 1
              Thread.new do
                mail_notify(user.email, @record.source.to_s, @record.message.to_s)
              end
              @record.email_notify = user.use_email_flag
            end
            if user.use_im_flag == 1
              Thread.new do
                im_notify(user.email, @record.source.to_s, @record.message.to_s)
              end
              @record.im_notify = user.use_im_flag
            end
            if user.use_mobile_ph_flag == 1
              Thread.new do
                sms_notify(user.mobile_phone_no, @record.source.to_s, @record.message.to_s)
              end
              @record.mobile_ph_notify = user.use_mobile_ph_flag
            end
            if user.use_nma_flag == 1
              Thread.new do
                nma_notify(user.nma_api_key, @record.source.to_s, @record.message.to_s)
              end
              @record.nma_notify = user.use_nma_flag
            end
            if user.use_nmwp_flag == 1
              Thread.new do
                nmwp_notify(user.nmwp_api_key, @record.source.to_s, @record.message.to_s)
              end
              @record.nmwp_notify = user.use_nmwp_flag
            end
            if user.use_prowl_flag == 1
              Thread.new do
                prowl_notify(user.prowl_api_key, @record.source.to_s, @record.message.to_s)
              end
              @record.prowl_notify = user.use_prowl_flag
            end
          end
        end

        Rails.logger.info "#{Time.now.utc} - Add #{@record.to_s} to records"
        user.records << @record
      end
    end
  end

  def notify_group(group_id, message)
    @group = Group.find_by_id(group_id)
    @users = @group.users.all

    if @users.nil?
      #do nothing
      Rails.logger.info "#{Time.now.utc} - Nil Users to notify in #{@group.title.to_s}"
    else
      @users.each do |user|
        #add notification to user feed
        Rails.logger.info "#{Time.now.utc} - User to Notify #{user.name.to_s}"
        @record = Record.new
        #for heartbeat & system rules where source is not defined
        @record.source = CONFIG[:core_settings][:app_name]
        @record.message = "#{message}"

        #check if user feed is longer than app settings
        if user.records.all.count > CONFIG[:core_settings][:event_history_length].to_i
          @first_event = user.records.all.first
          @first_event.destroy
        end

        #check user's timezone
        current_user_time = Time.now.utc + user.timezone.hours

        if (user.business_days == 0) || ((user.business_days == 5) && (current_user_time.wday != 0) && (current_user_time.wday != 6))
          #notifications disabled
        else
          #need to check time
          if (current_user_time.hour >= user.business_hrs_start) && (current_user_time.hour <= user.business_hrs_end)
            if user.use_boxcar_flag == 1
              #Thread.new do
                boxcar_notify(user.boxcar_id, @record.source.to_s, @record.message.to_s)
              #end
              @record.boxcar_notify = user.use_boxcar_flag
            end
            if user.use_email_flag == 1
              #Thread.new do
                mail_notify(user.email, @record.source.to_s, @record.message.to_s)
              #end
              @record.email_notify = user.use_email_flag
            end
            if user.use_im_flag == 1
              #Thread.new do
                im_notify(user.email, @record.source.to_s, @record.message.to_s)
              #end
              @record.im_notify = user.use_im_flag
            end
            if user.use_mobile_ph_flag == 1
              #Thread.new do
                sms_notify(user.mobile_phone_no, @record.source.to_s, @record.message.to_s)
              #end
              @record.mobile_ph_notify = user.use_mobile_ph_flag
            end
            if user.use_nma_flag == 1
              #Thread.new do
                nma_notify(user.nma_api_key, @record.source.to_s, @record.message.to_s)
              #end
              @record.nma_notify = user.use_nma_flag
            end
            if user.use_nmwp_flag == 1
              #Thread.new do
                nmwp_notify(user.nmwp_api_key, @record.source.to_s, @record.message.to_s)
              #end
              @record.nmwp_notify = user.use_nmwp_flag
            end
            if user.use_prowl_flag == 1
              #Thread.new do
                prowl_notify(user.prowl_api_key, @record.source.to_s, @record.message.to_s)
              #end
              @record.prowl_notify = user.use_prowl_flag
            end
          end
        end

        user.records << @record
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
        Rails.logger.info "#{Time.now.utc} - boxcar_register - #{username}"
      end
    else
      params = {'email' => username}
      post = Net::HTTP.post_form(URI.parse(CONFIG[:boxcar_settings][:public_notification__subscription_api_uri].to_s), params)
      Rails.logger.info "#{Time.now.utc} - boxcar_register - #{username}"
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
        Rails.logger.info "#{Time.now.utc} - mail_notify - #{username} - #{source_system} - #{message}"
      end
    end
  end

  #notify by sms(username, source_system, message)
  def sms_notify(username, source_system, message)
    sender = SmsGlobal::Sender.new :user => CONFIG[:sms_global_settings][:user_name].to_s, :password => CONFIG[:sms_global_settings][:password].to_s

    sender.send_text message, username, source_system
    Rails.logger.info "#{Time.now.utc} - sms_notify - #{username} - #{source_system} - #{message}"
  end

  def im_notify(username, source_system, message)
    #TODO figure out what to do about IM
  end

  #notify by prowl
  def prowl_notify(username, source_system, message)
    Prowly.notify do |n|
      n.apikey = username
      n.application = source_system
      n.event = "#{CONFIG[:core_settings][:app_name].to_s} Notification"
      n.description = message
    end
    Rails.logger.info "#{Time.now.utc} - prowl_notify - #{username} - #{source_system} - #{message}"
  end
end