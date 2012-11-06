require_relative 'rules_eng'
require_relative 'notification'

class RulesEngineCaller
  # To change this template use File | Settings | File Templates.
  attr_accessor :rule_engine, :rules_mutex, :last_processing_timestamp, :last_processing_duration, :fail_count, :last_processing_duration_history

  def initialize(rule_engine)
    @rule_engine = rule_engine
    @rules_mutex = Mutex.new
    #@last_processing_timestamp = Time.now.utc
    #@last_processing_duration = 0
    #@fail_count = 0
    @last_processing_duration_history = Array.new
  end

  def rebuild_engine
    Rails.logger.debug "#{Time.now.utc} - Acquiring Mutex"
    @rules_mutex.synchronize {
      Rails.logger.debug "#{Time.now.utc} - Mutex Acquired"
      #get rid of all terminated events on a reload
      @terminated_event = Event.find_all_by_terminate_flag('1')
      @terminated_event.each do |ended_ticket|
        Event.where(:ticket_id => ended_ticket.ticket_id, :source => ended_ticket.source).destroy_all
      end

      #get rid of all 'records' older than the retention date
      @old_record = Record.where("updated_at < ?", CONFIG[:core_settings][:event_history_length].to_i.days.ago)
      @old_record.each do |old_ticket|
        old_ticket.destroy
      end

      #get rid of all events that arent used by any rules
      #@invalid_source_events = Event.where(:source != Rule.select(:source).uniq.source)
      #@invalid_source_events.each do |invalid_source_ticket|
        #Rails.logger.info "No Rule Source Match, Deleting Record: ticket_id - #{invalid_source_ticket.ticket_id} | source - #{invalid_source_ticket.source} | cust region - #{invalid_source_ticket.cust_region} | description - #{invalid_source_ticket.description} | created at - #{invalid_source_ticket.created_at}"
        #Event.destroy(invalid_source_ticket)
      #end

      @rule_engine = Ruleby::Core::Engine.new
      EngineRulebook.new(@rule_engine).rules

      #@events = Event.select("call_type, ctc_id, cust_no, entitlement_code, group_owner, id, milestone, milestone_type, other_text, priority, source, start_time, target_time, ticket_id, time_stamp, description")
      @events = Event.all
      Rails.logger.debug "#{Time.now.utc} - Started loading Events"
      @admin_group = Group.find_by_title("Notification Admin")
      @events.each do |event|
        if event.call_type.nil? == false and event.ctc_id.nil? == false and event.cust_no.nil? == false and event.entitlement_code.nil? == false and event.group_owner.nil? == false and event.id.nil? == false and event.milestone.nil? == false and event.milestone_type.nil? == false and event.other_text.nil? == false and event.priority.nil? == false and event.source.nil? == false and event.start_time.nil? == false and event.target_time.nil? == false and event.ticket_id.nil? == false and event.time_stamp.nil? == false and event.description.nil? == false
          @rule_engine.assert event
        else
          Rails.logger.debug "#{Time.now.utc} - #{event} is Nil"
          MSG_NOTIFY.notify_group(@admin_group, "Nil Event - Call Type #{event.call_type} | CTC #{event.ctc_id} | Cust No #{event.cust_no} | Cust Region #{event.cust_region} | \nDescription #{event.description} | \nEntitlement Code #{event.entitlement_code} | Group Owner #{event.group_owner} | Milestone #{event.milestone} | Milestone Type #{event.milestone_type} | \nOther Text #{event.other_text} | Priority #{event.priority} | Source #{event.source} | \nStart Time #{event.start_time} | Target Time #{event.target_time} | Time Stamp #{event.time_stamp} | Terminate Flag #{event.terminate_flag} | \nTicket ID #{event.target_time} |")
          Event.destroy(event)
        end
      end
      Rails.logger.debug "#{Time.now.utc} - Finished loading Events"
      Rails.logger.debug "#{Time.now.utc} - Releasing Mutex"
    }
    Rails.logger.debug "#{Time.now.utc} - Mutex Released"
  end

  def run_engine
    Rails.logger.debug "#{Time.now.utc} - Run Engine"
    d = Time.now.utc
    puts "#{Time.now.utc} - Run Engine"
    Rails.logger.debug "#{Time.now.utc} - Acquiring Mutex"
    @rules_mutex.synchronize {
      Rails.logger.debug "#{Time.now.utc} - Mutex Acquired"
      @rule_engine.match

      #hard coded alert condition if running engine takes too long
      if (Time.now.utc - d) > CONFIG[:core_settings][:threshold].to_i
        @fail_count = @fail_count + 1
        Rails.logger.debug "#{Time.now.utc} - Processing above set threshold #{Time.now.utc - d} seconds, fail count #{@fail_count}"
        if @fail_count == 5
          MSG_NOTIFY.notify_group(1, "Alert Processing above set threshold x5, last processing #{Time.now.utc - d} seconds")
        elsif @fail_count == 30
          MSG_NOTIFY.notify_group(1, "Alert Processing above set threshold x30, last processing #{Time.now.utc - d} seconds")
        elsif @fail_count == 60
          MSG_NOTIFY.notify_group(1, "Alert Processing above set threshold x60, last processing #{Time.now.utc - d} seconds")
          @fail_count = 0
        end
      else
        @fail_count = 0
      end
      Rails.logger.debug "#{Time.now.utc} - Releasing Mutex"
      }
    Rails.logger.debug "#{Time.now.utc} - Mutex Released"
    Rails.logger.debug "#{Time.now.utc} - Finished Engine Match #{Time.now.utc - d} "
    @last_processing_timestamp = Time.now.utc
    @last_processing_duration = Time.now.utc - d

    #add values to an array for use with tracking history
    if @last_processing_duration_history.length > 20
      @last_processing_duration_history.shift
      @last_processing_duration_history << @last_processing_duration
    else
      @last_processing_duration_history << @last_processing_duration
    end
  end

  def assert_event(event)
    #@rule_engine.assert event
    if event.call_type.nil? == false and event.ctc_id.nil? == false and event.cust_no.nil? == false and event.entitlement_code.nil? == false and event.group_owner.nil? == false and event.id.nil? == false and event.milestone.nil? == false and event.milestone_type.nil? == false and event.other_text.nil? == false and event.priority.nil? == false and event.source.nil? == false and event.start_time.nil? == false and event.target_time.nil? == false and event.ticket_id.nil? == false and event.time_stamp.nil? == false and event.description.nil? == false
      @rule_engine.assert event
    else
      Rails.logger.debug "#{Time.now.utc} - #{event} is Nil"
      MSG_NOTIFY.notify_group(@admin_group, "Nil Event - Call Type #{event.call_type} | CTC #{event.ctc_id} | Cust No #{event.cust_no} | Cust Region #{event.cust_region} | \nDescription #{event.description} | \nEntitlement Code #{event.entitlement_code} | Group Owner #{event.group_owner} | Milestone #{event.milestone} | Milestone Type #{event.milestone_type} | \nOther Text #{event.other_text} | Priority #{event.priority} | Source #{event.source} | \nStart Time #{event.start_time} | Target Time #{event.target_time} | Time Stamp #{event.time_stamp} | Terminate Flag #{event.terminate_flag} | \nTicket ID #{event.target_time} |")
      Event.destroy(event)
    end
  end
end

