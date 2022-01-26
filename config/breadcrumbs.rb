crumb :root do
  link "Dashboard", root_path
end

crumb :new_short_url_request do
  link "Request a new URL redirect or short URL", new_short_url_request_path
  parent :root
end

crumb :short_url_requests do
  link "URL redirect or short URL requests", short_url_requests_path
  parent :root
end

crumb :live_short_urls do
  link "Live URL redirects and short URLs", list_short_urls_path
  parent :root
end

crumb :short_url_request do |short_url_request|
  link "View short URL request", short_url_request_path(short_url_request)
  parent :short_url_requests
end

crumb :edit_short_url_request do |short_url_request|
  link "Edit URL redirect or short URL", edit_short_url_request_path(short_url_request)
  parent :short_url_request, short_url_request
end

crumb :remove_short_url_request do |short_url_request|
  link "Remove short URL", remove_short_url_request_path(short_url_request)
  parent :short_url_request, short_url_request
end

crumb :reject_short_url_request do |short_url_request|
  link "Reject URL redirect or short URL", reject_short_url_request_path(short_url_request)
  parent :short_url_request, short_url_request
end

crumb :short_url_request_accepted do |short_url_request|
  link "URL redirect or short URL request accepted"
  parent :short_url_request, short_url_request
end

crumb :short_url_request_accepted_failed do |short_url_request|
  link "URL redirect or short URL request accept failed"
  parent :short_url_request, short_url_request
end
