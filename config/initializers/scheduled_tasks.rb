require 'rufus/scheduler'
require 'RulesEngineCaller'

scheduler = Rufus::Scheduler.start_new

rule_engine = Ruleby::Core::Engine.new
n = RulesEngineCaller.new(rule_engine)
EngineRulebook.new(rule_engine).rules

scheduler.every('10s', :blocking => true, :allow_overlapping => false) do
  n.run_engine
end
scheduler.every('30s', :blocking => true, :allow_overlapping => false) do
  n.rebuild_engine
end