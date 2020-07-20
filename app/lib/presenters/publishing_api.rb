module Presenters
  module PublishingAPI
    def self.present(redirect)
      {
        "base_path" => redirect.from_path,
        "document_type" => "redirect",
        "schema_name" => "redirect",
        "publishing_app" => "short-url-manager",
        "update_type" => "major",
        "redirects" => [
          {
            "path" => redirect.from_path,
            "type" => redirect.route_type,
            "segments_mode" => redirect.segments_mode,
            "destination" => redirect.to_path,
          },
        ],
      }
    end
  end
end
