def patch_class(clazz, patch)
  clazz.send(:include, patch) unless clazz.include?(patch)
end

Rails.configuration.to_prepare do
  patch_class Mailer, ControlDateReminder::Patches::MailerPatch
end

Redmine::Plugin.register :redmine_control_date_reminder do
  name 'Redmine Reminder plugin'
  author 'Leanid Masilevich'
  description 'This is a plugin for sending reminders in Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
