require_relative 'notification'
require 'ruleby'
include Ruleby

class EngineRulebook < Rulebook
  def rules
    Rails.logger.debug "#{Time.now.utc} - Loading Rules into Rulebook"
    #msg = Notification.new()
    @rules = Rule.all

    @rules.each do |rule_name|
      case
        ##### Rules for no other text & no ctc #####
        # milestone 1 =, other text na, ctc na, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #output matched rule to console & logfile
              Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

              #do actual alert
              MSG_NOTIFY.notify_user(rule_name.id, v[:m].id)

              #add reference so rule doesn't fire again
              @event = Event.find_by_id(v[:m].id)
              @event.rules << rule_name
              v[:m].rules << rule_name
              modify v[:m]
            end
            #if updating a bunch of records last updated, then do it here
          end
        #milestone1 =, no other text, no ctc, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && (rule_name.milestone1_time_value_denomination == "H" || rule_name.milestone1_time_value_denomination == "D")
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.milestone_type =~ /^D|^S/, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #find the last event
              @last_event = Event.where(:ticket_id => v[:m].ticket_id, :source => v[:m].source, :milestone_type => ['D', 'S']).order(:time_stamp).select(:id).last
              #check current event against the last duration type event
              if v[:m].id == @last_event.id
                if rule_name.milestone1_time_value_denomination == "H"
                  #convert hours to minutes
                  target_minutes = (rule_name.milestone1_time_value * 60).to_int
                  milestone1_target_time = (v[:m].time_stamp + target_minutes.minutes)
                elsif rule_name.milestone1_time_value_denomination == "D"
                  #convert days to minutes
                  target_minutes = (rule_name.milestone1_time_value * 60 * 24).to_int
                  milestone1_target_time = (v[:m].time_stamp + target_minutes.minutes)
                else
                  #erroneous data error, do not trigger but record in log
                  milestone1_target_time = Time.now.utc - 5.years
                  Rails.logger.warn "#{Time.now.utc} - DATA ERROR in #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
                end

                #check time now against the target specified
                if Time.now.utc >= milestone1_target_time
                  #matches condition
                  #output matched rule to console & logfile
                  Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

                  #do actual alert
                  MSG_NOTIFY.notify_user(rule_name.id, v[:m].id)

                  #add reference so rule doesn't fire again
                  @event = Event.find_by_id(v[:m].id)
                  @event.rules << rule_name
                  v[:m].rules << rule_name
                  modify v[:m]
                else
                  #do nothing, time hasn't expired yet - allows for check on next cycle
                end
              else
                #not the last event for duration calculation
                #add reference so rule doesn't fire again
                @event = Event.find_by_id(v[:m].id)
                @event.rules << rule_name
                v[:m].rules << rule_name
                modify v[:m]
              end
            end
          end
        #milestone1 =, other text na, ctc na, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #if the total count of events with the matching milestone is = the rule value
              if Event.where(:ticket_id => v[:m].ticket_id, :source => v[:m].source, :milestone => v[:m].milestone).count >= rule_name.milestone1_time_value.to_int
                #if (this rule & ticket id has not fired) or (fired & target time changed)
                if (Record.where(:event_id_ref => (Event.where(:ticket_id => v[:m].ticket_id, :source => v[:m].source).select(:id)), :rule_id_ref => rule_name.id).count > 0)
                  #matches condition
                  #output matched rule to console & logfile
                  Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

                  #do actual alert
                  MSG_NOTIFY.notify_user(rule_name.id, v[:m].id)
                end
                #add reference so rule doesn't fire again
                @event = Event.find_by_id(v[:m].id)
                @event.rules << rule_name
                v[:m].rules << rule_name
                modify v[:m]
              else
                #doesnt match condition
                #add a reference so rule doesn't fire again
                @event = Event.find_by_id(v[:m].id)
                @event.rules << rule_name
                v[:m].rules << rule_name
                modify v[:m]
              end
            end
            #if updating a bunch of records last updated, then do it here
          end
        #target time, other text na, ctc na, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #find the last event
              @last_event = Event.where(:ticket_id => v[:m].ticket_id, :source => v[:m].source, :milestone_type => ['D', 'S']).order(:time_stamp).select(:id).last
              #check current event against the last duration type event
              if v[:m].id == @last_event.id
                #is the last event so need to check the target against current
                if v[:m].target_time.nil? == false
                  #convert the target to a date
                  if rule_name.target_time_value_denomination == "H"
                    #convert hours to minutes
                    target_minutes = (rule_name.target_time_value * 60).to_int
                    target_target_time = (v[:m].target_time - target_minutes.minutes)
                  elsif rule_name.target_time_value_denomination == "D"
                    #convert days to minutes
                    target_minutes = (rule_name.target_time_value * 60 * 24).to_int
                    target_target_time = (v[:m].target_time - target_minutes.minutes)
                  elsif rule_name.target_time_value_denomination == "%"
                    #determine current %
                    target_remaining_perc = (rule_name.target_time_value / 100)
                    total_minutes = ((v[:m].target_time - v[:m].start_time) / 60)
                    target_minutes = (total_minutes * target_remaining_perc).to_int
                    target_target_time = (v[:m].target_time - target_minutes.minutes)
                  else
                    #erroneous data error, do not trigger but record in log
                    target_target_time = Time.now.utc - 5.years
                    Rails.logger.warn "#{Time.now.utc} - DATA ERROR in #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
                  end

                  #matches the condition
                  if Time.now.utc >= target_target_time and not (Time.now.utc - 5.minutes) >= target_target_time
                    #find this rule & ticket id match
                    @last_history = Record.where(:event_id_ref => (Event.where(:ticket_id => v[:m].ticket_id, :source => v[:m].source, :milestone_type => ['D', 'S']).order(:time_stamp).select(:id)), :rule_id_ref => rule_name.id).select(:event_id_ref).last
                    #if (this rule & ticket id has not fired) or (fired & target time changed)
                    if (@last_history.nil? == true) or (Event.find_by_id(@last_history.event_id_ref).target_time != v[:m].target_time)
                      #matches condition
                      #output matched rule to console & logfile
                      Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

                      #do actual alert
                      MSG_NOTIFY.notify_user(rule_name.id, v[:m].id)
                    end
                    #add reference so rule doesn't fire again
                    @event = Event.find_by_id(v[:m].id)
                    @event.rules << rule_name
                    v[:m].rules << rule_name
                    modify v[:m]
                  else
                    #if not past defined target then do nothing might be on the next cycle
                  end
                else
                  #no target date specified unable to calculate a target
                  #skip adding to exclude in case value is added in later milestones
                end
              else
                #not the last event for duration calculation
                #add reference so rule doesn't fire again

                @event = Event.find_by_id(v[:m].id)
                @event.rules << rule_name
                v[:m].rules << rule_name
                modify v[:m]
              end
            end
          end
        ##### Rules for other text = & ctc != #####
        # milestone 1 =, other text na, ctc !=, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, no other text, ctc !=, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id.not == rule_name.ctc_id_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text na, ctc !=, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text na, ctc !=, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for no other text & ctc = #####
        # milestone 1 =, other text na, ctc =, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text na, ctc =, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id == rule_name.ctc_id_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text na, ctc =, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text na, ctc=, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for other text = & ctc = #####
        # milestone 1 =, other text =, ctc =, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text =, ctc =, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text =, ctc =, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text =, ctc=, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.other_text == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for other text = & ctc na #####
        # milestone 1 =, other text =, ctc na, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text =, ctc na, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text =, ctc na, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text =, ctc na, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.other_text == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for other text != & ctc na #####
        # milestone 1 =, other text !=, ctc na, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc na, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc na, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text !=, ctc na, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.other_text.not == rule_name.other_text_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for other text != & ctc = #####
        # milestone 1 =, other text !=, ctc =, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc =, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc =, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text !=, ctc=, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.other_text.not == rule_name.other_text_value, m.ctc_id == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        ##### Rules for other text = & ctc != #####
        # milestone 1 =, other text =, ctc !=, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text == rule_name.other_text_value, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc =, duration based
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination != "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.ctc_id.not == rule_name.ctc_id_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #milestone1 =, other text !=, ctc =, milestone count
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_time_value_denomination == "count"
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text.not == rule_name.other_text_value, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
        #target time, other text !=, ctc=, duration based
        when rule_name.target_time_operator == "<" && rule_name.other_text_operator == "!=" && rule_name.ctc_id_operator == "!=" && rule_name.milestone1_operator == ""
          rule [Event, :m, m.milestone_type =~ /^D/, m.other_text.not == rule_name.other_text_value, m.ctc_id.not == rule_name.ctc_id_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|

          end
      end
    end
  end
end