class User
  include Mongoid::Document
  include GDS::SSO::User

  field :name, type: String
  field :email, type: String
  field :uid, type: String
  field :organisation_slug, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false

  def can_request_furls?
    permissions.include? 'request_furls'
  end

  def can_manage_furls?
    permissions.include? 'manage_furls'
  end
end
