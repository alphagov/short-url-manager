class RedirectContentIdRestorer
  def perform!
    redirects_missing_content_ids = Redirect.where(content_id: nil)
    base_paths_to_lookup = redirects_missing_content_ids.map(&:from_path)
    mapped_content_ids = GdsApi.publishing_api.lookup_content_ids(base_paths: base_paths_to_lookup, exclude_document_types: [])
    updates = []
    mapped_content_ids.each do |from_path, content_id|
      updates << {
        update_one: {
          filter: { from_path: },
          update: { '$set': { content_id: } },
        },
      }
    end
    Redirect.collection.bulk_write(updates)

    Rails.logger.info "Restored content IDs for #{mapped_content_ids.size} of #{redirects_missing_content_ids.size} redirects missing content IDs."
  end
end
