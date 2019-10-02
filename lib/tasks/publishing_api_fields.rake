namespace :publishing_api_fields do
  desc "Set default value for route_type field for Redirects"
  task set_default_route_type: :environment do
    Redirect.where(route_type: nil).update_all(route_type: "exact")
  end

  desc "Set default value for segments_mode field for Redirects"
  task set_default_segments_mode: :environment do
    Redirect.where(segments_mode: nil).update_all(segments_mode: "ignore")
  end
end
