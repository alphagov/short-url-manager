require 'gds_api/publishing_api_v2'
require "securerandom"

class Redirect
  include Mongoid::Document
  include Mongoid::Timestamps
  include ShortUrlValidations

  field :content_id, type: String
  field :from_path, type: String
  field :to_path, type: String
  field :route_type, type: String
  field :segments_mode, type: String

  belongs_to :short_url_request, required: false

  validates :from_path, uniqueness: true

  before_save :create_redirect_in_publishing_api
  after_initialize :ensure_presence_of_content_id

private

  def create_redirect_in_publishing_api
    payload = Presenters::PublishingAPI.present(self)
    publishing_api.put_content(content_id, payload)
    publishing_api.publish(content_id, :major)
  rescue GdsApi::HTTPErrorResponse => e
    Airbrake.notify(e, params: payload)
    errors.add(:base, "An error posting to the publishing API prevented this redirect from being created: #{e}")
    throw :abort # Do not continue to save
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.current.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def ensure_presence_of_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
