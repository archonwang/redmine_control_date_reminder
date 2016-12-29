require File.expand_path('../../test_helper', __FILE__)

class ControlDateReminderTest < ActiveSupport::TestCase
	include Redmine::I18n
  include Rails::Dom::Testing::Assertions
  fixtures :projects, :issues, :users, :custom_fields, :custom_values

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.plain_text_mail = '0'
    Setting.default_language = 'ru'
    User.current = nil
  end

  def test_remind_users
  	ControlDateReminder.remind_users(days: 3, field_id: 1)
    assert_equal 2, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries[1]
    assert mail.bcc.include?('author@somenet.foo')
    assert_equal "Напоминание о дате контроля задач постановщику задач", mail.subject
    assert_mail_body_match 'Cannot print recipes', mail
    mail = ActionMailer::Base.deliveries[0]
    assert mail.bcc.include?('assigned_to@somenet.foo')
    assert_equal "Напоминание о дате контроля задач исполнителю", mail.subject
  end

  def test_remind_users_for_users_id
    ControlDateReminder.remind_users( :users => [1])
    assert_equal 0, ActionMailer::Base.deliveries.size
    ControlDateReminder.remind_users(:users => [4])
    assert_equal 1, ActionMailer::Base.deliveries.size 
    mail = last_email
    assert mail.bcc.include?('author@somenet.foo')
    assert_mail_body_match 'Cannot print recipes', mail
  end

  def test_remind_users_for_field_id
    ControlDateReminder.remind_users( field_id: 2)
    assert_equal 2, ActionMailer::Base.deliveries.size
    mail = last_email
    assert mail.bcc.include?('admin@somenet.foo')
    assert_mail_body_match 'Add ingredients categories', mail
  end

  def test_remind_managers
    ControlDateReminder.remind_managers
    assert_equal 2, ActionMailer::Base.deliveries.size
    mail = last_email
    assert mail.bcc.include?('manager_2@somenet.foo')
    assert_mail_body_match 'Issue on project 2 for manager2', mail
    assert_mail_body_no_match 'Cannot print recipes', mail
    mail = ActionMailer::Base.deliveries.first
    assert mail.bcc.include?('manager_1@somenet.foo')
    assert_mail_body_match 'Cannot print recipes', mail
    assert_mail_body_no_match 'Issue on project 2 for manager2', mail
  end

  def test_remind_managers_for_users_id
    ControlDateReminder.remind_managers( :users => [2])
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = last_email
    assert mail.bcc.include?('manager_1@somenet.foo')
    assert_mail_body_match 'Cannot print recipes', mail
    assert_mail_body_no_match 'Issue on project 2 for manager2', mail
  end

  private

  def last_email
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    mail
  end

end