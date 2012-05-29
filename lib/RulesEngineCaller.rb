require_relative 'rules_eng'
#TODO switch this with the actual rules_eng_loader

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

    @events.each do |event|
      @rule_engine.assert event
    end
  end

  def run_engine
    @rule_engine.match
  end

  def add_fact__to_engine
    #TODO need to pass current 'event' to add to existing engine
    #@rule_engine.assert Verification_Record.new('SC00000067890', 'WTR', 'INC', 'REMEDY')
    #@rule_engine.assert Event.new(call_type => 'INC', milestone => 'WTR', ticket_id => 'SC00000067890', source => 'REMEDY')
    @rule_engine.match
  end
end

