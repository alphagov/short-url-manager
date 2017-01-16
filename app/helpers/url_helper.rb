module UrlHelper
  def govuk_url_for(path)
    (Plek.current.website_uri + path).to_s
  end

  def short_url_manger_url_for(path)
    (Plek.current.find('short-url-manager') + path).to_s
  end
end
