require 'yaml'
# Load the rails application
require File.expand_path('../application', __FILE__)

# Load app config yml (notification passwords & settings)
CONFIG = YAML.load_file(File.dirname(__FILE__) + "/app_config.yml") # From file

# Initialize the rails application
Notificationv2::Application.initialize!