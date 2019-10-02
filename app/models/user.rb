class User
  include Mongoid::Document
  include GDS::SSO::User

  field :name, type: String
  field :email, type: String
  field :uid, type: String
  field :organisation_slug, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false
  field :disabled, type: Boolean, default: false
  field :organisation_content_id, type: String

  scope :short_url_managers, -> { where(permissions: /manage_short_urls/) }
  scope :notification_recipients, -> { where(permissions: /receive_notifications/) }

  def can_request_short_urls?
    permissions.include? "request_short_urls"
  end

  def can_manage_short_urls?
    permissions.include? "manage_short_urls"
  end
end
