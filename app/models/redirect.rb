require 'gds_api/publishing_api'
require "securerandom"

class Redirect
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content_id, type: String
  field :from_path, type: String
  field :to_path, type: String

  belongs_to :short_url_request

  validates :from_path, :to_path, presence: true
  validates :from_path, :to_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
  validates :from_path, uniqueness: true

  before_save :create_redirect_in_publishing_api
  after_initialize :ensure_presence_of_content_id

private
  def create_redirect_in_publishing_api
    payload = Presenters::PublishingAPI.present(self)
    publishing_api.put_content_item(from_path, payload)
  rescue GdsApi::HTTPErrorResponse => e
    Airbrake.notify_or_ignore(e, :params => payload)
    errors.add(:base, "An error posting to the publishing API prevented this redirect from being created: #{e}")
    false # Do not continue to save
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.current.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def ensure_presence_of_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
