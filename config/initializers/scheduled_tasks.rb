require 'rufus/scheduler'
require 'RulesEngineCaller'

debug = false
scheduler = Rufus::Scheduler.start_new(:frequency => 1.0)
Rails.logger = Logger.new("rule-log.txt", 'daily')

Rails.logger.debug "#{Time.now.utc} - Created Notification Object"
MSG_NOTIFY = Notification.new()

rule_engine = Ruleby::Core::Engine.new
Rails.logger.debug "#{Time.now.utc} - Created New Rules Engine"
RULES_ENG = RulesEngineCaller.new(rule_engine)
unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
  EngineRulebook.new(rule_engine).rules

  if debug == true
    sleep 30
    @events = Event.all
    @records = Record.all
    @me = User.find_by_email("andrew.bills@ventyx.abb.com")

    MSG_NOTIFY.prowl_notify(@me.prowl_api_key, CONFIG[:core_settings][:app_name].to_s, "Debug Process Start")

    @events.each do |event|
      event.destroy
    end

    MSG_NOTIFY.prowl_notify(@me.prowl_api_key, CONFIG[:core_settings][:app_name].to_s, "Debug Process All Events Destroyed, starting on Records")

    @records.each do |record|
      record.destroy
    end

    MSG_NOTIFY.prowl_notify(@me.prowl_api_key, CONFIG[:core_settings][:app_name].to_s, "Debug Process Done")

  else
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
end

def scheduler.handle_exception(job, exception)
  Rails.logger.debug "#{Time.now.utc} - job #{job.job_id} caught exception '#{exception}'"

  #personal notification while debugging
  #@me = User.find_by_email("andrew.bills@ventyx.abb.com")
  #MSG_NOTIFY.prowl_notify(@me.prowl_api_key, CONFIG[:core_settings][:app_name].to_s, "#{Time.now.utc} - job #{job.job_id} caught exception '#{exception}'")
end