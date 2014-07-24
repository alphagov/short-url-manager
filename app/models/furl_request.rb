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

  validates :from, :to, :reason, :organisation_slug, :organisation_title, presence: true
  validates :contact_email, presence: true, format: { with: /\A[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})\z/ }

  before_validation :retreive_organisation_title, unless: ->{ organisation_title.present? }

private
  def retreive_organisation_title
    self.organisation_title = Organisation.where(slug: organisation_slug).first.try(:title)
  end
end
