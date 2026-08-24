# frozen_string_literal: true

class RequestStatusComponent < ViewComponent::Base
  COLOURS = {
    "accepted" => "green",
    "pending" => "blue",
    "rejected" => "red",
    "superseded" => "grey",
  }.freeze

  def initialize(short_url_request)
    super()
    @short_url_request = short_url_request
  end

  def text
    @short_url_request.state.titleize
  end

  def colour
    COLOURS.fetch(@short_url_request.state, "grey")
  end
end
