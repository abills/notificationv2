require 'ruleby'
include Ruleby

class Verification_Record
  def initialize(ticket_id, milestone, call_type, source)
    @milestone = milestone
    @ticket_id = ticket_id
    @call_type = call_type
    @source = source
    @time_stamp = 0 #TODO need timestamp
    @cust_no = 11111 #TODO need customer number
    @cust_region = "Bobs Country Bunker" #TODO need customer defined + Not used for rules only notification
    @other_text = "random text here" #TODO need other type text field
    @priority = 1 #TODO need priority
    @group_owner = "MMS-UNIX-ADMIN" #TODO need group owner
    @ctc_id = 123 #TODO need CTC code
    @entitlement_code = 4 #TODO need entitlement code
    @description = "test verification data"
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