module ApplicationHelper
  def would_overwrite_existing?(short_url_request)
    short_url_request.similar_redirects.detect { |r| r[:from_path] == short_url_request.from_path }
  end
end
