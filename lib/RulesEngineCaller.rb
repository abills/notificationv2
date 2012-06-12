require_relative 'rules_eng'

class RulesEngineCaller
  # To change this template use File | Settings | File Templates.
  attr_accessor :rule_engine

  def initialize(rule_engine)
    @rule_engine = rule_engine
  end

  def rebuild_engine
    #TODO need to add deleting all terminated events on a reload to clear out engine
    #Event.delete_all(:ticket_id => v[:m].ticket_id, :source => v[:m].source)

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
end

