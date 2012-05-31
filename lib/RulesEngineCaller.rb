require_relative 'rules_eng'

class RulesEngineCaller
  # To change this template use File | Settings | File Templates.
  attr_accessor :rule_engine

  def initialize(rule_engine)
    @rule_engine = rule_engine
  end

  def rebuild_engine
    #TODO need to be able to ditch facts & rules and reload with current facts and current rules
    @rule_engine = Ruleby::Core::Engine.new
    EngineRulebook.new(@rule_engine).rules

    #if rake fails need to disable this call until after db:create is done
    @events = Event.all

    puts "Loading Events #{Time.now.utc}"
    Rails.logger.debug "#{Time.now.utc} - started loading events"

    @events.each do |event|
      @rule_engine.assert event
    end

    puts "Finished Loading Events #{Time.now.utc}"
    Rails.logger.debug "#{Time.now.utc} - finished loading events"
  end

  def run_engine
    d = Time.now.utc
    puts "run engine"
    Rails.logger.debug "#{Time.now.utc} - run engine"
    @rule_engine.match
    puts "finished engine match #{Time.now.utc - d}"
    Rails.logger.debug "#{Time.now.utc} - finished engine match #{Time.now.utc - d} "
  end

  def add_fact__to_engine
    #TODO need to pass current 'event' to add to existing engine
    #@rule_engine.assert Verification_Record.new('SC00000067890', 'WTR', 'INC', 'REMEDY')
    @rule_engine.match
    Rails.logger.debug "#{Time.now.utc} - fact pushed"
  end
end

