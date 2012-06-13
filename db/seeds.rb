# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
##
# M E T H O D S
##
# @param [String] name
# @param [String] email
# @param [stri] password
# @param [Array] roles
def createUser(name, email, password, roles)
  user = User.find_or_create_by_email :name => name,
                                      :email => email,
                                      :password => password,
                                      :password_confirmation => password,
                                      :confirmed_at => DateTime.now,
                                      :business_days => 5,
                                      :business_hrs_start => 9,
                                      :business_hrs_end => 17,
                                      :timezone => 0
  roles.each do |role|
    user.add_role role.to_sym
  end
  user.reset_authentication_token!
  user
end

def createGroup(name)
  group = Group.find_or_create_by_title :title => name
  group
end

def createRule(name, groupname, message)
  rule = Rule.find_or_create_by_title :title => name,
                                      :group_id => Group.find_by_title(groupname),
                                      :syntax_msg => message
  rule
end


puts 'SETTING UP DEFAULT USER LOGIN'
puts 'New user created: ' << createUser("Neil Pennell", 'neil.pennell@ventyx.abb.com', "password", [:SystemAdmin, :admin]).name
puts 'New user created: ' << createUser("Andrew Bills", 'andrew.bills@ventyx.abb.com', 'password', [:SystemAdmin, :admin]).name
puts 'New group created:' << createGroup('Notification Admin').title
puts 'New rule created: ' << createRule('SYSTEM ADMIN - auto-clean delete rule', 'Notification Admin', 'Auto-clean no notification do not delete').title
puts 'New rule created: ' << createRule('SYSTEM ADMIN - heartbeat rule', 'Notification Admin', 'Heartbeat failed for source').title

