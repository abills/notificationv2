require_relative 'rules_eng'
require_relative 'notification'

class RulesEngineCaller
  # To change this template use File | Settings | File Templates.
  attr_accessor :rule_engine, :rules_mutex, :last_processing_timestamp, :last_processing_duration, :fail_count

  def initialize(rule_engine)
    @rule_engine = rule_engine
    @rules_mutex = Mutex.new
    @last_processing_timestamp = Time.now.utc
    @last_processing_duration = 0
    @fail_count = 0
  end

  def rebuild_engine
    Rails.logger.debug "#{Time.now.utc} - Acquiring Mutex"
    @rules_mutex.synchronize {
      Rails.logger.debug "#{Time.now.utc} - Mutex Acquired"
      #get rid of all terminated events on a reload
      @terminated_event = Event.find_all_by_terminate_flag('1')
      @terminated_event.each do |ended_ticket|
        Event.destroy_all(:ticket_id => ended_ticket.ticket_id, :source => ended_ticket.source)
      end

      #@old_records = Record.all.where(records.created_at < Date.parse(CONFIG[:core_settings][:event_history_length].to_i.days.ago))
      #@old_records.destroy

      @rule_engine = Ruleby::Core::Engine.new
      EngineRulebook.new(@rule_engine).rules

      #if rake fails need to disable this call until after db:create is done
      @events = Event.all

      Rails.logger.debug "#{Time.now.utc} - Started loading Events"

      @events.each do |event|
        @rule_engine.assert event
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
  end

  def assert_event(event)
    @rule_engine.assert event
  end
end

