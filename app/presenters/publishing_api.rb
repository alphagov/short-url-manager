module Presenters
  module PublishingAPI
    def self.present(redirect)
      {
        "content_id" => redirect.content_id,
        "base_path" => redirect.from_path,
        "document_type" => "redirect",
        "schema_name" => "redirect",
        "publishing_app" => "short-url-manager",
        "update_type" => "major",
        "redirects" => [
          { "path" => redirect.from_path, "type" => "exact", "destination" => redirect.to_path }
        ]
      }
    end
  end
end
