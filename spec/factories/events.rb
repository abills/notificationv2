# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    milestone "MyString"
    ticket_id "MyString"
    call_type "MyString"
    source "MyString"
    time_stamp "2012-05-25 13:21:20"
    cust_no "MyString"
    cust_region "MyString"
    other_text "MyString"
    priority 1
    group_owner "MyString"
    ctc_id "MyString"
    entitlement_code "MyString"
    description "MyString"
    milestone_type "MyString"
    terminate_flag 1
  end
end
