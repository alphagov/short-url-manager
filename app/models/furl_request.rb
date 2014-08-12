class FurlRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :state, type: String, default: 'pending'
  field :from, type: String
  field :to, type: String
  field :reason, type: String
  field :contact_email, type: String
  field :organisation_slug, type: String
  field :organisation_title, type: String
  field :rejection_reason, type: String

  belongs_to :requester, class_name: "User"
  has_one :furl, inverse_of: :request

  validates :state, :from, :to, :reason, :contact_email, :organisation_slug, :organisation_title, presence: true
  validates :contact_email, format: { with: /\A[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})\z/ }, allow_blank: true
  validates :from, :to, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
  validates :state, inclusion: { in: %w(pending accepted rejected) }, allow_blank: true

  before_validation :retreive_organisation_title, unless: ->{ organisation_title.present? }

  def accept!
    new_furl = Furl.new(from: from, to: to, request: self)
    if new_furl.save
      update_attributes state: 'accepted'
      Notifier.furl_request_accepted(self).deliver
      true
    else
      false
    end
  end

  def reject!(reason = nil)
    update_attributes state: 'rejected',
                      rejection_reason: reason
    Notifier.furl_request_rejected(self).deliver
    true
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

private
  def retreive_organisation_title
    self.organisation_title = Organisation.where(slug: organisation_slug).first.try(:title)
  end
end
