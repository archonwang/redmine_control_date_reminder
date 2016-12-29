module ControlDateReminder

	def self.remind_users(options={})
    self.read_options(options)

    scope = Issue.open.where("issues.assigned_to_id IS NOT NULL" +
      " AND issues.id  IN " +
      "(SELECT issues.id FROM issues LEFT OUTER JOIN custom_values ON custom_values.customized_type='Issue'" + 
        " AND custom_values.customized_id=issues.id AND custom_values.custom_field_id=?" + 
        " WHERE ((custom_values.value <= ?) AND custom_values.value <> '')) ",@field_id, @days.day.from_now.to_date)

    issues_by_assignee = @user_ids.present? ? scope.where(:assigned_to_id => @user_ids) : scope
    issues_by_assignee = issues_by_assignee.includes(:status, :assigned_to, :project, :tracker).
                              group_by(&:assigned_to)


    issues_by_author = @user_ids.present? ? scope.where(:author_id => @user_ids) : scope
    issues_by_author = issues_by_author.includes(:status, :assigned_to, :project, :tracker).
                              group_by(&:author)

    issues_by_assignee.keys.each do |assignee|
      if assignee.is_a?(Group)
        assignee.users.each do |user|
          issues_by_assignee[user] ||= []
          issues_by_assignee[user] += issues_by_assignee[assignee]
        end
      end
    end

    issues_by_assignee.each do |assignee, issues|
      Mailer.reminder_by_control_date(assignee, issues, @days, @field_id, :assigned_to).deliver if assignee.is_a?(User) && assignee.active?
    end

    issues_by_author.each do |author, issues|
      Mailer.reminder_by_control_date(author, issues, @days, @field_id, :author).deliver if author.is_a?(User) && author.active?
    end
	end

  def self.remind_managers(options={})
    self.read_options(options)

    manager_ids = Role.find_by_name("Менеджер").members.group(:user_id).map(&:user_id)

    p "manager_ids = " + manager_ids.join(", ")
    p "@user_ids = " + @user_ids.join(", ")
    p (manager_ids & @user_ids).join(", ")

    ids = @user_ids.present? ? (manager_ids & @user_ids) : manager_ids

    managers = User.find(ids)

    managers.each do |manager|
      issues = Issue.find_by_sql(["SELECT DISTINCT issues.*, issues.id FROM roles LEFT JOIN member_roles ON roles.id = member_roles.role_id" +
        " LEFT JOIN members ON member_roles.member_id = members.id LEFT JOIN users ON users.id = members.user_id" +
        " LEFT JOIN projects ON projects.id = members.project_id LEFT JOIN issues ON issues.project_id = projects.id" +
        " LEFT JOIN issue_statuses ON issue_statuses.id = issues.status_id" +
        " WHERE issue_statuses.is_closed = 'f' AND roles.name = 'Менеджер' AND users.id = :user_id AND issues.assigned_to_id IS NOT NULL " +
        " AND issues.id  IN (SELECT issues.id FROM issues LEFT OUTER JOIN custom_values ON custom_values.customized_type='Issue' " + 
        " AND custom_values.customized_id=issues.id AND custom_values.custom_field_id= :field_id" +
        " WHERE ((custom_values.value <= :custom_value AND custom_values.value <> ''))) ", 
        {user_id: manager.id, field_id: @field_id, custom_value: @days.day.from_now.to_date}])

      Mailer.reminder_by_control_date(manager, issues, @days, @field_id, :manager).deliver if issues.any? && manager.is_a?(User) && manager.active?
    end
    
  end

  private   
  def self.read_options(options={})
    @days = options[:days] || 1
    @user_ids = options[:users]
    @field_id = options[:field_id] || 1
  end

end