module ApplicationHelper
  def crumb_li(title, path)
    options = {}
    options[:class] = "govuk-breadcrumbs__list-item"

    tag.li nil, **options do
      link_to(title, path, class: "govuk-breadcrumbs__link")
    end
  end

  def would_overwrite_existing?(short_url_request)
    short_url_request.similar_redirects.detect { |r| r[:from_path] == short_url_request.from_path }
  end
end
