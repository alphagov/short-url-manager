class BreadcrumbsComponent < ViewComponent::Base
  def initialize(breadcrumbs)
    super()
    @breadcrumbs = breadcrumbs
  end

  def crumbs
    all_but_last_crumb = @breadcrumbs.reject { |crumb| crumb == @breadcrumbs.last }
    all_but_last_crumb.map do |crumb|
      {
        title: crumb.text,
        url: crumb.url,
      }
    end
  end

  def render?
    crumbs.size > 1
  end
end
