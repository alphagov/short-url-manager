module PublishingApiHelper
  def publishing_api_redirect_hash(from_path, to_path)
    {
      "base_path" => from_path,
      "format" => "redirect",
      "redirects" => [
        {"path" => from_path, "type" => "exact", "destination" => to_path}
      ]
    }
  end
end
