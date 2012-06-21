# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_record do
    event_date "2012-06-14 08:54:50"
    source "MyString"
    message "MyString"
  end
end
