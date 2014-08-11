class FurlRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: String
  field :to, type: String
  field :reason, type: String
  field :contact_email, type: String
  field :organisation_slug, type: String
  field :organisation_title, type: String

  belongs_to :requester, class_name: "User"
  has_one :furl

  validates :from, :to, :reason, :contact_email, :organisation_slug, :organisation_title, presence: true
  validates :contact_email, format: { with: /\A[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})\z/ }, allow_blank: true
  validates :from, :to, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true

  before_validation :retreive_organisation_title, unless: ->{ organisation_title.present? }

private
  def retreive_organisation_title
    self.organisation_title = Organisation.where(slug: organisation_slug).first.try(:title)
  end
end
