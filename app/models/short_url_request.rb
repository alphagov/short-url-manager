class ShortUrlRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include ShortUrlValidations

  field :state, type: String, default: 'pending'
  field :from_path, type: String
  field :to_path, type: String
  field :reason, type: String
  field :contact_email, type: String
  field :organisation_slug, type: String
  field :organisation_title, type: String
  field :rejection_reason, type: String

  belongs_to :requester, class_name: "User"
  has_one :redirect

  validates :state, :reason, :contact_email, :organisation_slug, :organisation_title, presence: true
  validates :state, inclusion: { in: %w(pending accepted rejected superseded) }, allow_blank: true
  validate :not_already_live

  before_validation :retrieve_organisation_title, if: ->{ organisation_slug_changed? }
  before_validation :strip_whitespace, :only => [:from_path, :to_path]

  scope :pending, -> { where(state: "pending") }

  attr_accessor :confirmed

  def similar_redirects
    @similar_redirects ||= Redirect.or({from_path: from_path}, {to_path: to_path})
  end

  def similar_requests
    @similar_requests ||= ShortUrlRequest.where(from_path: from_path, :id.ne => self.id).order_by([:created_at, :asc])
  end

  def pending?
    state == 'pending'
  end

  def accepted?
    state == 'accepted'
  end

  def rejected?
    state == 'rejected'
  end

  def superseded?
    state == 'superseded'
  end

private
  def not_already_live
    if Redirect.where(from_path: from_path, to_path: to_path).present?
      errors.add(:base, 'The specified Short URL already redirects to the specified Target URL')
      false
    end
  end

  def retrieve_organisation_title
    self.organisation_title = Organisation.where(slug: organisation_slug).first.try(:title)
  end

  def strip_whitespace
    self.from_path = self.from_path.strip
    self.to_path = self.to_path.strip
  end
end
