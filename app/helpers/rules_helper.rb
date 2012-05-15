module RulesHelper
  def build_sql_query(id)
    @rule = Rule.find(params[id])

    db_name = "db_name"
    table_name = "table_name"

    temp_sql = "select `#{db_name}`.`#{table_name}`.* from `#{db_name}`.`#{table_name}` where "
    #add limits
    #add source to sql statement
    if not @rule.source.blank?
      temp_sql.concat("source =\"#{@rule.source}\"")
    end
    #add customer no to sql statement
    if not @rule.cust_no.blank?
      temp_sql.concat(" and cust_no =\"#{@rule.cust_no}\"")
    end
    #add call_type to sql statement
    if @rule.call_type != "NULL"
      temp_sql.concat(" and call_type =\"#{@rule.call_type}\"")
    end
    #add priority to sql statement
    if @rule.priority != 0
      temp_sql.concat(" and priority =#{@rule.priority}")
    end
    #add group_owner to sql statement
    if not @rule.group_owner.blank?
      temp_sql.concat(" and group_owner =\"#{@rule.group_owner}\"")
    end
    #add entitlement_code to sql statement
    if not @rule.entitlement_code.blank?
      temp_sql.concat(" and entitlement_code =\"#{@rule.entitlement_code}\"")
    end
    #add milestone rule condition
    if @rule.milestone1_operator != "NULL"
      case @rule.milestone1_operator
        when "="
          temp_sql.concat(" and milestone #{@rule.milestone1_operator}\"#{@rule.milestone1_value}\"")
          #if milestone duration needs to be used
          if @rule.milestone1_time_value_denomination != "NULL"
            temp_sql.concat(" and milestone_timestamp >#{@rule.milestone1_time_value}#{@rule.milestone1_time_value_denomination}")
          end
        when "count"
          temp_sql.concat(" !!!add count for milestones!!! ")
      end
      #add target time operators
      if @rule.target_time_operator != "NULL" and @rule.target_time_value_denomination != "NULL"
        temp_sql.concat(" and target_time #{@rule.target_time_operator}#{@rule.target_time_value}#{@rule.target_time_value_denomination}")
      end
      #add CTC rule condition
      if @rule.ctc_id_operator != "NULL"
        temp_sql.concat(" and ctc_id #{@rule.ctc_id_operator}\"#{@rule.ctc_id_value}\"")
      end
      #add other text rule condition
      if @rule.other_text_operator != "NULL"
        case @rule.other_text_operator
          when "="
            temp_sql.concat(" and other_text #{@rule.other_text_operator}\"#{@rule.other_text_value}\"")
          when "!="
            temp_sql.concat(" and other_text #{@rule.other_text_operator}\"#{@rule.other_text_value}\"")
          when ">"
            temp_sql.concat(" and other_text #{@rule.other_text_operator}\"#{@rule.other_text_value}\"")
          when "<"
            temp_sql.concat(" and other_text #{@rule.other_text_operator}\"#{@rule.other_text_value}\"")
          when "count"
            temp_sql.concat(" !!!add count for other text!!! ")
        end
      end
    end

    return temp_sql
  end
end
