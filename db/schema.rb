# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120910082957) do

  create_table "events", :force => true do |t|
    t.string   "milestone"
    t.string   "ticket_id"
    t.string   "call_type"
    t.string   "source"
    t.datetime "time_stamp"
    t.datetime "target_time"
    t.datetime "start_time"
    t.string   "cust_no"
    t.string   "cust_region"
    t.string   "other_text"
    t.string   "priority"
    t.string   "group_owner"
    t.string   "ctc_id"
    t.string   "entitlement_code"
    t.string   "description"
    t.string   "milestone_type"
    t.integer  "terminate_flag"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "events_rules", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "rule_id"
  end

  add_index "events_rules", ["event_id", "rule_id"], :name => "index_events_rules_on_event_id_and_rule_id"

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id"

  create_table "records", :force => true do |t|
    t.string   "source"
    t.string   "message"
    t.integer  "rule_id_ref"
    t.integer  "boxcar_notify"
    t.integer  "nma_notify"
    t.integer  "nmwp_notify"
    t.integer  "mobile_ph_notify"
    t.integer  "im_notify"
    t.integer  "email_notify"
    t.integer  "salesforce_notify"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "prowl_notify"
    t.integer  "event_id_ref"
  end

  add_index "records", ["user_id"], :name => "index_records_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "rules", :force => true do |t|
    t.string   "title"
    t.integer  "group_id"
    t.string   "syntax_msg"
    t.string   "group_owner"
    t.string   "source"
    t.string   "cust_no"
    t.string   "priority"
    t.string   "entitlement_code"
    t.string   "call_type"
    t.string   "other_text_operator"
    t.string   "other_text_value"
    t.string   "ctc_id_operator"
    t.string   "ctc_id_value"
    t.string   "milestone1_operator"
    t.string   "milestone1_value"
    t.float    "milestone1_time_value"
    t.string   "milestone1_time_value_denomination"
    t.string   "milestone2_operator"
    t.string   "milestone2_value"
    t.float    "milestone2_time_value"
    t.string   "milestone2_time_value_denomination"
    t.string   "target_time_operator"
    t.float    "target_time_value"
    t.string   "target_time_value_denomination"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "rules", ["group_id"], :name => "index_rules_on_group_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "country_iso"
    t.string   "mobile_phone_no"
    t.string   "boxcar_id"
    t.integer  "use_mobile_ph_flag"
    t.integer  "use_email_flag"
    t.integer  "use_im_flag"
    t.integer  "use_boxcar_flag"
    t.string   "salesforce_id"
    t.integer  "use_salesforce_flag"
    t.integer  "business_hrs_start"
    t.integer  "business_hrs_end"
    t.integer  "business_days"
    t.string   "nma_api_key"
    t.integer  "use_nma_flag"
    t.string   "nmwp_api_key"
    t.integer  "use_nmwp_flag"
    t.string   "rss_token"
    t.float    "timezone"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "prowl_api_key"
    t.integer  "use_prowl_flag"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id", "invited_by_type"], :name => "index_users_on_invited_by_id_and_invited_by_type"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_records", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "record_id"
  end

  add_index "users_records", ["user_id", "record_id"], :name => "index_users_records_on_user_id_and_record_id"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
