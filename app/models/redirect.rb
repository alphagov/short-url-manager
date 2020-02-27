require "gds_api/publishing_api_v2"
require "securerandom"

class Redirect
  include Mongoid::Document
  include Mongoid::Timestamps
  include ShortUrlValidations

  field :content_id, type: String
  field :from_path, type: String
  field :to_path, type: String
  field :route_type, type: String, default: "exact"
  field :segments_mode, type: String, default: "ignore"
  field :override_existing, type: Boolean, default: false

  belongs_to :short_url_request, optional: true

  validates :from_path, uniqueness: true

  before_save :create_redirect_in_publishing_api
  before_destroy :unpublish_in_publishing_api
  after_initialize :ensure_presence_of_content_id

private

  def create_redirect_in_publishing_api
    payload = Presenters::PublishingAPI.present(self)
    if override_existing?
      GdsApi.publishing_api_v2.put_path(
        from_path,
        publishing_app: "short-url-manager",
        override_existing: true,
      )
    end
    GdsApi.publishing_api_v2.put_content(content_id, payload)
    GdsApi.publishing_api_v2.publish(content_id, :major)
  rescue GdsApi::HTTPErrorResponse => e
    GovukError.notify(e, extra: payload)
    errors.add(:base, "An error posting to the publishing API prevented this redirect from being created: #{e}")
    throw :abort # Do not continue to save
  end

  def unpublish_in_publishing_api
    GdsApi.publishing_api_v2.unpublish(content_id, type: "gone")
  end

  def ensure_presence_of_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
