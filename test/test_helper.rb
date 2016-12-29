# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', 
	[:projects, :users, :roles, :issues, :custom_fields, :custom_values, :email_addresses, :members, :member_roles])