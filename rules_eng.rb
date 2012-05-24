require 'ruleby'
include Ruleby

class Verification_Record
  def initialize(ticket_id, milestone, call_type, source)
    @milestone = milestone
    @ticket_id = ticket_id
    @call_type = call_type
    @source = source
    @time_stamp = 0 #TODO need timestamp - EPOC time
    @cust_no = 11111 #TODO need customer number
    @cust_region = "Bobs Country Bunker" #TODO need customer defined + Not used for rules only notification
    @other_text = "random text here" #TODO need other type text field
    @priority = 1 #TODO need priority
    @group_owner = "MMS-UNIX-ADMIN" #TODO need group owner
    @ctc_id = 123 #TODO need CTC code
    @entitlement_code = 4 #TODO need entitlement code
    @description = "test verification data"
    @milestone_type = "d" #TODO need to define milestone time at entry, either e or d (event or duration), time since only available with duration milestones.
  end
  attr :milestone, true
  attr :ticket_id, true
  attr :call_type, true
  attr :source, true
  attr :description, true
end


class EngineRulebook < Rulebook
  # To change this template use File | Settings | File Templates.
  def rules
    puts "Checking rules"
    rule [Verification_Record, :m, m.milestone == "AKR", m.source =~ /(REMEDY|^)/] do |v|
      puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
    end
    rule [Verification_Record, :m, m.milestone == "WTR", m.source == "REMEDY"] do |v|
      puts "#{v[:m].ticket_id} | match rule #{v[:m].milestone} - #{v[:m].description}"
    end

    blah = Appl
  end
end

engine :engine do |e|
  EngineRulebook.new(e).rules
  e.assert Verification_Record.new('SC00000012345', 'AKR', 'INC', 'REMEDY')
  e.assert Verification_Record.new('SC00000067890', 'WTR', 'INC', 'REMEDY')
  e.assert Verification_Record.new('SC00000067890', 'CRR', 'INC', 'REMEDY')

  puts "Loaded data"
  e.match
end

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