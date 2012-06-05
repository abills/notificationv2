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
  end

  def add_fact__to_engine
    #TODO need to pass current 'event' to add to existing engine
    #@rule_engine.assert Verification_Record.new('SC00000067890', 'WTR', 'INC', 'REMEDY')
    @rule_engine.match
    Rails.logger.debug "#{Time.now.utc} - Fact pushed"
  end
end

