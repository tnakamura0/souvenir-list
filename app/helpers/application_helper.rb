module ApplicationHelper
  def navigation_active?(section)
    case section
    when :today
      controller_name == "today"
    when :trips
      controller_name.in?(%w[trips trip_recipients])
    when :recipients
      controller_name.in?(%w[recipients tags])
    end
  end
end
