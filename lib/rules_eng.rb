require 'ruleby'
include Ruleby

class EngineRulebook < Rulebook
  # To change this template use File | Settings | File Templates.
  def rules
    puts "loading rules"
    @rules = Rule.all

    @rules.each do |rule_name|

    end

    rule [Event, :m, m.milestone == "AKR", m.source =~ /(REMEDY|^)/] do |v|
      #puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
    end
    rule [Event, :m, m.milestone == "WTR", m.source == "REMEDY"] do |v|
      #puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
    end
    rule [Event, :m, m.terminate_flag == 1] do |v|
      puts "#{v[:m].ticket_id} | Need to Delete - #{v[:m].description}"
      @event = Event.find_all_by_ticket_id(v[:m].ticket_id)
      #TODO need to add check for source to go with find_by_ticket_id -> ###.where(:source => v[:m].source) ?
      @event.each do |event_id|
        event_id.delete
      end

      retract v[:m]
      #TODO need to add that this rule has already fired and add it to the rule conditions to check
      #TODO add these actions to a application log for auditing
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