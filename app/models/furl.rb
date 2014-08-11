require 'gds_api/publishing_api'

class Furl
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: String
  field :to, type: String

  belongs_to :request, class_name: "FurlRequest"

  validates :from, :to, presence: true
  validates :from, :to, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true

  before_save :create_redirect_in_publishing_api

private
  def create_redirect_in_publishing_api
    publishing_api.put_content_item(from, {
      "base_path" => from,
      "format" => "redirect",
      "redirects" => [
        {"path" => from, "type" => "exact", "destination" => to}
      ]
    })
  rescue GdsApi::HTTPErrorResponse
    errors.add(:base, "An error prevented the redirect for this friendly URL being created")
    false # Do not continue to save
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
  end
end
