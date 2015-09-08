module ApplicationHelper
  def crumb_li(title, path, active)
    options = {}
    options[:class] = 'active' if active

    content_tag :li, nil, options do
      active ? title : link_to(title, path)
    end
  end
end
