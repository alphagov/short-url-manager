module PublishingApiHelper
  def publishing_api_redirect_hash(from_path, to_path, content_id)
    {
      "content_id" => content_id,
      "base_path" => from_path,
      "document_type" => "redirect",
      "schema_name" => "redirect",
      "publishing_app" => "short-url-manager",
      "update_type" => "major",
      "redirects" => [
        {"path" => from_path, "type" => "exact", "destination" => to_path}
      ]
    }
  end
end
