require_relative 'rules_eng'
require_relative 'notification'

class RulesEngineCaller
  # To change this template use File | Settings | File Templates.
  attr_accessor :rule_engine

  def initialize(rule_engine)
    @rule_engine = rule_engine
  end

  def rebuild_engine
    #get rid of all terminated events on a reload
    @terminated_event = Event.find_all_by_terminate_flag('1')
    @terminated_event.each do |ended_ticket|
      Event.destroy_all(:ticket_id => ended_ticket.ticket_id, :source => ended_ticket.source)
    end

    @rule_engine = Ruleby::Core::Engine.new
    EngineRulebook.new(@rule_engine).rules

    #if rake fails need to disable this call until after db:create is done
    @events = Event.all

    puts "#{Time.now.utc} - Loading Events"
    Rails.logger.debug "#{Time.now.utc} - Started loading Events"

    @events.each do |event|
      @rule_engine.assert event
    end

    puts "#{Time.now.utc} - Finished Loading Events"
    Rails.logger.debug "#{Time.now.utc} - Finished loading Events"
  end

  def run_engine
    d = Time.now.utc
    puts "#{Time.now.utc} - Run Engine"
    Rails.logger.debug "#{Time.now.utc} - Run Engine"
    @rule_engine.match
    puts "#{Time.now.utc} - Finished Engine Match #{Time.now.utc - d}"
    Rails.logger.debug "#{Time.now.utc} - Finished Engine Match #{Time.now.utc - d} "

    #hard coded alert condition if running engine takes too long
    if (Time.now.utc - d) > CONFIG[:core_settings][:threshold].to_i
      $fail_count += 1
      if session[:threshold_exceeded] = 5
        notify_group(1, "Alert Processing above set threshold x5, last processing #{Time.now.utc - d} seconds")
      elsif session[:threshold_exceeded] = 30
        notify_group(1, "Alert Processing above set threshold x30, last processing #{Time.now.utc - d} seconds")
      elsif session[:threshold_exceeded] = 60
        notify_group(1, "Alert Processing above set threshold x60, last processing #{Time.now.utc - d} seconds")
        $fail_count = 0
      end
    else
      $fail_count = 0
    end
  end
end

