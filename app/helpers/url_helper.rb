module UrlHelper
  def govuk_url_for(path)
    (Plek.current.website_uri + path).to_s
  end
end
