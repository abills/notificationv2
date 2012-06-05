require 'ruleby'
include Ruleby

class EngineRulebook < Rulebook
  def rules
    puts "#{Time.now.utc} - Loading Rules into Rulebook"
    Rails.logger.debug "#{Time.now.utc} - Loading Rules into Rulebook"
    @rules = Rule.all

    @rules.each do |rule_name|
      case
        #hard coded rule - for auto cleaning
        when (rule_name.title == "SYSTEM ADMIN - auto-clean delete rule") && (rule_name.group.title == "Notification Admin")
          rule [Event, :m, m.terminate_flag == 1] do |v|
            if v[:m].rules.include?(rule_name) == false
              #output matched rule to console & logfile
              puts "match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
              Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

              #add reference so rule doesn't fire again
              #TODO can remove the next 2 lines when have figured out how to delete the entries properly
              @event = Event.find_by_id(v[:m].id)
              @event.rules << rule_name
              v[:m].rules << rule_name
              modify v[:m]

              #remove all entries of the terminated event
              #TODO re-enable the below line when thats figured out too
              #Event.delete_all(:ticket_id => v[:m].ticket_id, :source => v[:m].source)
            end
          end
        # milestone 1 =, no other text, no ctc, denomination not used
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == ""
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #output matched rule to console & logfile
              puts "match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
              Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

              #do actual alert
              #or queue alert to be done by another task?
              #pass event id & rule id to function for alerting

              #add reference so rule doesn't fire again
              @event = Event.find_by_id(v[:m].id)
              @event.rules << rule_name
              v[:m].rules << rule_name
              modify v[:m]
            end
          end
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination != "count"
          #milestone1 =, no other text, no ctc, duration based
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.milestone_type =~ /^D|^S/,m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              #find the last event
              @last_event = Event.where(ticket_id: v[:m].ticket_id).where("milestone_type != ?", 'E').last
              #check current event against the last duration type event
              if v[:m].id == @last_event.id
                if rule_name.milestone1_time_value_denomination == "H"
                  #convert hours to minutes
                  milestone1_time_value_minutes = rule_name.milestone1_time_value * 60
                elsif rule_name.milestone1_time_value_denomination == "D"
                  #convert days to minutes
                  milestone1_time_value_minutes = rule_name.milestone1_time_value * 60 * 24
                end

                #check time now against the target specified
                if Time.now.utc >= ((v[:m].created_at) + milestone1_time_value_minutes.minutes)
                  #matches condition
                  #output matched rule to console & logfile
                  puts "match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
                  Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

                  #do actual alert
                  #or queue alert to be done by another task?
                  #pass event id & rule id to function for alerting

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
        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value_denomination == "count"
          #milestone1 =, no other text, no ctc, milestone count
          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.source =~ /#{rule_name.source}|^$/, m.cust_no =~ /#{rule_name.cust_no}|^$/, m.call_type =~ /#{rule_name.call_type}|^$/, m.priority =~ /#{rule_name.priority}|^$/, m.group_owner =~ /#{rule_name.group_owner}|^$/, m.entitlement_code =~ /#{rule_name.entitlement_code}|^$/ ] do |v|
            #check if rule has already fired
            if v[:m].rules.include?(rule_name) == false
              @events = Event.find_all_by_ticket_id_and_source(v[:m].ticket_id, v[:m].source)
              @event_count = Event.find_all_by_ticket_id_and_source_and_milestone(v[:m].ticket_id, v[:m].source, v[:m].milestone)

              if @event_count.count() == rule_name.milestone1_time_value.to_int
                #matches condition
                #output matched rule to console & logfile
                puts "match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"
                Rails.logger.info "#{Time.now.utc} - match rule #{rule_name.id} #{rule_name.title} - #{v[:m].ticket_id} - #{v[:m].description}"

                #do actual alert
                #or queue alert to be done by another task?
                #pass event id & rule id to function for alerting

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
          end
        when rule_name.milestone1_operator == "" && rule_name.other_text_operator == "" && rule_name.ctc_id_operator == "" && rule_name.milestone1_time_value == "<"
          #target time, duration based
          #includes rule condition for milestone being duration based
      end
    end
  end
end

#####################################################################################################

#check if rule has fired on another event for the same ticket & source
#if @events.include?(:rule => rule_name) == false
#  puts "#{@event_count.count()} #{v[:m].id} #{v[:m].ticket_id} #{@events.include?(:rule => rule_name)}"
  #check if rule conditions match


#else
  #rule has fired before on another event
#end

#####################################################################################################

#        when rule_name.milestone1_operator == "=" && rule_name.other_text_operator == "=" && rule_name.ctc_id_operator == "=" && rule_name.milestone1_time_value_denomination == "NULL"
#          # milestone 1 =, other text =, ctc =, denomination not used
#          puts "load - milestone 1 =, other text =, ctc =, denomination not used"
#          rule [Event, :m, m.milestone == rule_name.milestone1_value, m.other_text_value == rule_name.other_text_value, m.ctc_id_value == rule_name.ctc_id_value, m.milestone1_time_value_denomination == rule_name.milestone1_time_value_denomination, m.source =~ /(#{rule_name.source}|^)/, m.cust_no =~ /(#{rule_name.cust_no}|^)/, m.call_type =~ /(#{rule_name.call_type}|^)/, m.priority =~ /(#{rule_name.priority}|^)/, m.group_owner =~ /(#{rule_name.group_owner}|^)/, m.entitlement_code =~ /(#{rule_name.entitlement_code}|^)/] do |v|
#            #check if rule has already fired
#            if v[:m].rules.include?(Rule.find_by_id(rule_name.id)) == false
#              #output matched rule to console & logfile
#              puts "match rule #{rule_name.id} - #{v[:m].ticket_id} - #{v[:m].description}"
#              Rails.logger.info "#{Time.now.utc} - match delete rule #{rule_name.id} - #{v[:m].ticket_id} - #{v[:m].description}"
#
#              #add reference so rule doesn't fire again
#              @event = Event.find_by_id(v[:m].id)
#              @event.rules << rule_name
#              v[:m].rules << rule_name
#              modify v[:m]
#            end
#          end

#####################################################################################################
#if a duration type rule find last
#@Last_event = Event.where(ticket_id: v[:m].ticket_id).last

#do stuff

#notify

#add reference so rule doesn't fire again
#@event = Event.find_by_id(v[:m].id)
#@event.rules << rule_name
#v[:m].rules << rule_name
#modify v[:m]

#####################################################################################################

#rule [Event, :m, m.milestone == "AKR", m.source =~ /(REMEDY|^)/] do |v|
#puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"

#rule [Event, :m, m.milestone == "WTR", m.source =~ /(REMEDY|^)/] do |v|
#puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
#TODO need to add that this rule has already fired and add it to the rule conditions to check
#add matched rule to event
#TODO need to know how to add stuff to an existing hash in a model for another example it would be adding the rule name
#end
#end

#####################################################################################################

#@rules = Rule.all

#@rules.each do |rule_name|
#case
#  when (rule_name.milestone1_operator == "=" or rule_name.milestone1_operator == ">") #milestone is equals or count
#    puts "condition 1"
#    puts "#{rule_name.ticket_id} | match rule #{rule_name.milestone} - #{rule_name.description}"
#  when rule_name.target_time_operator == "<" #time to target is <
#    puts "condition 2"
#    puts "#{rule_name.ticket_id} | match rule #{rule_name.milestone} - #{rule_name.description}"
#end
#end

#puts "Default Rules"
#rule [Event, :m, m.milestone == "AKR", m.source =~ /(REMEDY|^)/] do |v|
#  puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
#end
#rule [Event, :m, m.milestone == "WTR", m.source == "REMEDY"] do |v|
#  puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
#end

#####################################################################################################

#rules.each do |rulename|
#  case
#    when rulename.milestone_operator == "=" or rulename.milestone_operator == ">" #milestone is equals or count
#      case
#        when (other_text_operator == "=" or other_text_operator == "") and (ctc_id_operator == "=" or ctc_id_operator == "")
#          rule rulename.id [verification_data, :m, m.milestone == rulename.milestone1_value, m.other_text =~ /(#{rulename.other_text_value}|^)/, m.ctc_id_value =~ /(#{rulename.ctc_id_value}|^)/, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            if rulename.milestone_operator == ">"
#              #verify if ticket_id, rule & verification data line have been matched before
#              #notify all users with the matching group subscription & update the rule match log
#            else #assume equals
#                 #check if duration since has been specified as part of the rule, if so check if event is the latest
#                 #verify if ticket_id, rule & verification data line have been matched before
#                 #notify all users with the matching group subscription & update the rule match log
#            end
#          end
#        when (other_text_operator == "=" or other_text_operator == "") and (ctc_id_operator == "!")
#          rule rulename.id [verification_data, :m, m.milestone == rulename.milestone1_value, m.other_text =~ /(#{rulename.other_text_value}|^)/, m.ctc_id_value != rulename.ctc_id_value, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            if rulename.milestone_operator == ">"
#              #verify if ticket_id, rule & verification data line have been matched before
#              #notify all users with the matching group subscription & update the rule match log
#            else #assume equals
#                 #check if duration since has been specified as part of the rule, if so check if event is the latest
#                 #verify if ticket_id, rule & verification data line have been matched before
#                 #notify all users with the matching group subscription & update the rule match log
#            end
#          end
#        when (other_text_operator == "!") and (ctc_id_operator == "=" or ctc_id_operator == "")
#          rule rulename.id [verification_data, :m, m.milestone == rulename.milestone1_value, m.other_text =~ rulename.other_text_value, m.ctc_id_value =~ /(#{rulename.ctc_id_value}|^)/, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            if rulename.milestone_operator == ">"
#              #verify if ticket_id, rule & verification data line have been matched before
#              #notify all users with the matching group subscription & update the rule match log
#            else #assume equals
#                 #check if duration since has been specified as part of the rule, if so check if event is the latest
#                 #verify if ticket_id, rule & verification data line have been matched before
#                 #notify all users with the matching group subscription & update the rule match log
#            end
#          end
#      end
#    when rulename.target_time_operator_operator == "<" #time to target is <
#      case
#        when (other_text_operator == "=" or other_text_operator == "") and (ctc_id_operator == "=" or ctc_id_operator == "")
#          rule rulename.id [verification_data, :m, m.other_text =~ /(#{rulename.other_text_value}|^)/, m.ctc_id_value =~ /(#{rulename.ctc_id_value}|^)/, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            #check if event is the 'latest' duration event & compare time current to the time set
#            #verify if ticket_id, rule & verification data line have been matched before
#            #notify all users with the matching group subscription & update the rule match log
#          end
#        when (other_text_operator == "=" or other_text_operator == "") and (ctc_id_operator == "!")
#          rule rulename.id [verification_data, :m, m.other_text =~ /(#{rulename.other_text_value}|^)/, m.ctc_id_value != rulename.ctc_id_value, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            #check if event is the 'latest' duration event & compare time current to the time set
#            #verify if ticket_id, rule & verification data line have been matched before
#            #notify all users with the matching group subscription & update the rule match log
#          end
#        when (other_text_operator == "!") and (ctc_id_operator == "=" or ctc_id_operator == "")
#          rule rulename.id [verification_data, :m, m.other_text =~ rulename.other_text_value, m.ctc_id_value =~ /(#{rulename.ctc_id_value}|^)/, m.source =~ /(#{rulename.source}|^)/, m.cust_no =~ /(#{rulename.cust_no}|^)/, m.call_type =~ /(#{rulename.call_type}|^)/, m.priority =~ /(#{rulename.priority}|^)/, m.group_owner =~ /(#{rulename.group_owner}|^)/, m.entitlement_code =~ /(#{rulename.entitlement_code}|^)/] do |v|
#            #check if event is the 'latest' duration event & compare time current to the time set
#            #verify if ticket_id, rule & verification data line have been matched before
#            #notify all users with the matching group subscription & update the rule match log
#          end
#      end
#  end
#end