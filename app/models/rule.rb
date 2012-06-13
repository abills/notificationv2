class Rule < ActiveRecord::Base
  attr_accessible :title, :group_id, :group_owner, :source, :cust_no, :call_type, :priority, :entitlement_code, :milestone1_operator, :milestone1_value, :milestone1_time_value, :milestone1_time_value_denomination, :target_time_operator, :target_time_value, :target_time_value_denomination, :ctc_id_operator, :ctc_id_value, :other_text_operator, :other_text_value, :syntax_msg
  belongs_to :group
  has_many :events
  unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
    after_save :reload_rules_eng
  end

  validates_presence_of :group


  def reload_rules_eng
    RULES_ENG.rebuild_engine
  end
end
