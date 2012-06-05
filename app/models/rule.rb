class Rule < ActiveRecord::Base
  attr_accessible :title, :group_id, :group_owner, :source, :cust_no, :call_type, :priority, :entitlement_code, :milestone1_operator, :milestone1_value, :milestone1_time_value, :milestone1_time_value_denomination, :target_time_operator, :target_time_value, :target_time_value_denomination, :ctc_id_operator, :ctc_id_value, :other_text_operator, :other_text_value, :sql_query, :syntax_msg
  belongs_to :group
  #before_save :build_sql_query

  def build_sql_query
    db_name = "db_name"
    table_name = "table_name"

    temp_sql = "select `#{db_name}`.`#{table_name}`.* from `#{db_name}`.`#{table_name}` where "
    #add limits
    #add source to sql statement
    if not self.source.blank?
      temp_sql.concat("source =\"#{self.source}\"")
    end
    #add customer no to sql statement
    if not self.cust_no.blank?
      temp_sql.concat(" and cust_no =\"#{self.cust_no}\"")
    end
    #add call_type to sql statement
    if self.call_type != "NULL"
      temp_sql.concat(" and call_type =\"#{self.call_type}\"")
    end
    #add priority to sql statement
    if self.priority != 0
      temp_sql.concat(" and priority =#{self.priority}")
    end
    #add group_owner to sql statement
    if not self.group_owner.blank?
      temp_sql.concat(" and group_owner =\"#{self.group_owner}\"")
    end
    #add entitlement_code to sql statement
    if not self.entitlement_code.blank?
      temp_sql.concat(" and entitlement_code =\"#{self.entitlement_code}\"")
    end
    #add milestone rule condition
    if self.milestone1_operator != "NULL"
      case self.milestone1_operator
        when "="
          temp_sql.concat(" and milestone #{self.milestone1_operator}\"#{self.milestone1_value}\"")
          #if milestone duration needs to be used
          if self.milestone1_time_value_denomination != "NULL"
            temp_sql.concat(" and milestone_timestamp >#{self.milestone1_time_value}#{self.milestone1_time_value_denomination}")
          end
        when "count"
          temp_sql.concat(" !!!add count for milestones!!! ")
      end
      #add target time operators
      if self.target_time_operator != "NULL" and self.target_time_value_denomination != "NULL"
        temp_sql.concat(" and target_time #{self.target_time_operator}#{self.target_time_value}#{self.target_time_value_denomination}")
      end
      #add CTC rule condition
      if self.ctc_id_operator != "NULL"
        temp_sql.concat(" and ctc_id #{self.ctc_id_operator}\"#{self.ctc_id_value}\"")
      end
      #add other text rule condition
      if self.other_text_operator != "NULL"
        case self.other_text_operator
          when "="
            temp_sql.concat(" and other_text #{self.other_text_operator}\"#{self.other_text_value}\"")
          when "!="
            temp_sql.concat(" and other_text #{self.other_text_operator}\"#{self.other_text_value}\"")
          when ">"
            temp_sql.concat(" and other_text #{self.other_text_operator}\"#{self.other_text_value}\"")
          when "<"
            temp_sql.concat(" and other_text #{self.other_text_operator}\"#{self.other_text_value}\"")
          when "count"
            temp_sql.concat(" !!!add count for other text!!! ")
        end
      end
    end

    self.sql_query = temp_sql
  end
end
