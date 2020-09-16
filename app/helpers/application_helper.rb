module ApplicationHelper
  def crumb_li(title, path, active)
    options = {}
    options[:class] = "active" if active

    tag.li nil, **options do
      active ? title : link_to(title, path)
    end
  end

  def would_overwrite_existing?(short_url_request)
    short_url_request.similar_redirects.detect { |r| r[:from_path] == short_url_request.from_path }
  end
end
