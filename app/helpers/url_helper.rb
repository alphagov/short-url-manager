module UrlHelper
  def govuk_url_for(path)
    (Plek.website_root + path).to_s
  end

  def short_url_manger_url_for(path)
    (Plek.external_url_for("short-url-manager") + path).to_s
  end
end
