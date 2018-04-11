class FilterPresenter

  def get_users(name_or_email)
    users = User.all
    if name_or_email.present?
      users = User.where(*name_clauses(name_or_email))
    end
    users
  end

  def name_clauses(name)
    names = name.downcase.strip.split(" ")
    clauses = (["(users.first_name like ? or users.last_name like ? or users.email like ? or users.username like ?)"] * names.size).join(" and ")
    args = names.map{|x| ["%#{x}%"] * 4}
    [clauses,*args.flatten]
  end

end