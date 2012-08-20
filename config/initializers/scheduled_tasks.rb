require 'rufus/scheduler'
require 'RulesEngineCaller'

scheduler = Rufus::Scheduler.start_new(:frequency => 1.0)
Rails.logger = Logger.new("rule-log.txt", 'daily')

rule_engine = Ruleby::Core::Engine.new
Rails.logger.debug "#{Time.now.utc} - Created New Rules Engine"
RULES_ENG = RulesEngineCaller.new(rule_engine)
unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
  EngineRulebook.new(rule_engine).rules


  #initial data load in case no rules are changed at start
  scheduler.in('30s', :allow_overlapping => false) do
    Rails.logger.debug "#{Time.now.utc} - Added Rules & Facts to New Rules Engine"
    ActiveRecord::Base.connection_pool.with_connection do
      RULES_ENG.rebuild_engine
    end
  end

  #run re-occuring per schedule in config
  scheduler.every(CONFIG[:core_settings][:run_engine_time], :allow_overlapping => false) do
    ActiveRecord::Base.connection_pool.with_connection do
      RULES_ENG.run_engine
    end
  end
  scheduler.every(CONFIG[:core_settings][:forced_engine_restart], :allow_overlapping => false) do
    ActiveRecord::Base.connection_pool.with_connection do
      RULES_ENG.rebuild_engine
    end
  end
end

def scheduler.handle_exception(job, exception)
  Rails.logger.debug "#{Time.now.utc} - job #{job.job_id} caught exception '#{exception}'"
end