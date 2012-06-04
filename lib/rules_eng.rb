require 'ruleby'
include Ruleby

class EngineRulebook < Rulebook
  def rules
    puts "loading rules"
    Rails.logger.debug "#{Time.now.utc} - Loading Rules into Rulebook"
    @rules = Rule.all

    @rules.each do |rule_name|
      @rule_title = rule_name.id
      #TODO add loading rules loop
      case
        #hard coded rule - for auto cleaning
        when (rule_name.title == "SYSTEM ADMIN - auto-clean delete rule") && (rule_name.group.title == "Notification Admin")
          puts "load auto cleaning rule"
          rule [Event, :m, m.terminate_flag == 1] do |v|
            if v[:m].rules.include?(Rule.find_by_id(rule_name.id)) == false
              #matched rule to console & logfile
              puts "match #{:delete_rule} rule - #{v[:m].ticket_id} - #{v[:m].description}"
              Rails.logger.info "#{Time.now.utc} - match #{:delete_rule} rule - #{v[:m].ticket_id} - #{v[:m].description}"

              #add reference so rule doesn't fire again
              v[:m].rules << rule_name
              modify v[:m]

              #remove all entries of the terminated event
              Event.joins.delete_all(:ticket_id => v[:m].ticket_id, :source => v[:m].source)
              Event.destroy_all(:ticket_id => v[:m].ticket_id, :source => v[:m].source)
            end
          end

        #next when statement goes here
        #rule condition
        #check if rule has already fired

        #if a duration type rule find last
        #@Last_event = Event.where(ticket_id: v[:m].ticket_id).last

        #do stuff

        #notify

        #add reference so rule doesn't fire again
        #@event = Event.find_by_id(v[:m].id)
        #@event.rules << rule_name
        #v[:m].rules << rule_name
        #modify v[:m]
      end
    end

    rule [Event, :m, m.milestone == "AKR", m.source =~ /(REMEDY|^)/] do |v|
      #puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"



    end
    rule [Event, :m, m.milestone == "WTR", m.source =~ /(REMEDY|^)/] do |v|
      #puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
      #TODO need to add that this rule has already fired and add it to the rule conditions to check
      #add matched rule to event
      #TODO need to know how to add stuff to an existing hash in a model for another example it would be adding the rule name
    end
  end
end

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