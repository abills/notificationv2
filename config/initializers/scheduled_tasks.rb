require 'rufus/scheduler'
require 'RulesEngineCaller'

scheduler = Rufus::Scheduler.start_new
Rails.logger = Logger.new("rule-log.txt", 'daily')

rule_engine = Ruleby::Core::Engine.new
Rails.logger.debug "#{Time.now.utc} - Created New Rules Engine"
RULES_ENG = RulesEngineCaller.new(rule_engine)
unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
  EngineRulebook.new(rule_engine).rules
end

Rails.logger.debug "#{Time.now.utc} - Added Rules to New Rules Engine"

scheduler.every(CONFIG[:core_settings][:run_engine_time], :blocking => true, :allow_overlapping => false) do
  RULES_ENG.run_engine
end
scheduler.every(CONFIG[:core_settings][:forced_engine_restart], :blocking => true, :allow_overlapping => false) do
  RULES_ENG.rebuild_engine
end