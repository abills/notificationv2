require 'openwfe/util/scheduler'
require 'RulesEngineCaller'
include OpenWFE

scheduler = Scheduler.new
scheduler.start

rule_engine = Ruleby::Core::Engine.new
n = RulesEngineCaller.new(rule_engine)
EngineRulebook.new(rule_engine).rules

scheduler.schedule_every('5s'){n.run_engine}
scheduler.schedule_every('12s'){n.rebuild_engine}