# Load the rails application
require File.expand_path('../application', __FILE__)
require_relative 'my_script'

# Initialize the rails application
Notificationv2::Application.initialize!

n = Test_Thing.new
n.do_something


