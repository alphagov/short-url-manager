# frozen_string_literal: true

class ShortUrlRequestDataComponent < ViewComponent::Base
  def initialize(short_url_request:, show_short_url: true)
    super()
    @short_url_request = short_url_request
    @show_short_url = show_short_url
  end

  def items
    [
      {
        field: "Organisation",
        value: @short_url_request.organisation_title,
      },
      {
        field: "Requested at",
        value: @short_url_request.created_at.to_fs(:govuk_date),
      },
      *short_url_item,
      {
        field: "Target URL",
        value: helpers.link_to(@short_url_request.to_path, helpers.govuk_url_for(@short_url_request.to_path)),
      },
      {
        field: "Override existing",
        value: @short_url_request.override_existing? ? "Yes" : "No",
      },
      {
        field: "Route type",
        value: @short_url_request.route_type,
      },
      {
        field: "Segments mode",
        value: @short_url_request.segments_mode,
      },
      {
        field: "Reason",
        value: @short_url_request.reason,
      },
      {
        field: "Contact email",
        value: @short_url_request.contact_email,
      },
      {
        field: "State",
        value: @short_url_request.state.titleize,
      },
    ]
  end

private

  def short_url_item
    return [] unless @show_short_url

    [{ field: "URL redirect or short URL", value: @short_url_request.from_path }]
  end
end
