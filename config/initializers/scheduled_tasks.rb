require 'rufus/scheduler'
require 'RulesEngineCaller'

scheduler = Rufus::Scheduler.start_new
Rails.logger = Logger.new("rule-log.txt", 'daily')

rule_engine = Ruleby::Core::Engine.new
Rails.logger.debug "#{Time.now.utc} - Created New Rules Engine"
n = RulesEngineCaller.new(rule_engine)

#TODO figure out how to not run the next line if doing a rake
EngineRulebook.new(rule_engine).rules
Rails.logger.debug "#{Time.now.utc} - Added Rules to New Rules Engine"

scheduler.every('30s', :blocking => true, :allow_overlapping => false) do
  n.run_engine
end
scheduler.every('60s', :blocking => true, :allow_overlapping => false) do
  n.rebuild_engine
end