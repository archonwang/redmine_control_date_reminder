module ControlDateReminder
  module Patches
    module MailerPatch

      def reminder_by_control_date(user, issues, days, field_id, whom = :default)
        set_language_if_valid user.language
        subject = case whom
        when :author
          :mail_subject_reminder_by_control_date_to_author
        when :assigned_to
          :mail_subject_reminder_by_control_date_to_assigned_to
        when :manager
          :mail_subject_reminder_by_control_date_to_manager
        else
          :mail_subject_reminder_by_control_date
        end

        @issues = issues
        @days = days
        @field_id = field_id
        @issues_url = url_for(:controller => 'issues', :action => 'index',
                                    :set_filter => 1, :assigned_to_id => user.id)
        mail :to => user,
          :subject => l(subject)
      end

    end
  end
end