desc <<-END_DESC
Send reminders about issues by compare control date value with 'days' parameter.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * method   => method to calling from issue
  * args     => args array to send to method

Example:
  rake redmine:reminders_by_control_date days=1 users="1,23, 56" RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :reminders_by_control_date => :environment do
    require 'control_date_reminder'
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:field_id] = ENV['field_id'].to_i if ENV['field_id']
    options[:users] = (ENV['users'] || '').split(',').each(&:strip!)

    Mailer.with_synched_deliveries do
      ControlDateReminder.remind_users(options)
      ControlDateReminder.remind_managers(options)
    end
  end
end