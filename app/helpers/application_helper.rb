module ApplicationHelper
	def sort_link(column, title=nil, model=nil)
    title ||= column.titleize
    sort_column = (model == "user" ? sort_column_for_users : sort_column_for_tasks)
    direction = (column == sort_column) && (sort_direction == "asc") ? "desc" : "asc"
    icon = sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down"
    icon = (column == sort_column) ? icon : "fa fa-chevron-up"
    link_to "#{title} <span class='#{icon}'></span>".html_safe, {column: column, direction: direction}
  end
end
