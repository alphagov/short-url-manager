class ShortUrlRequest
  include Mongoid::Document
  include Mongoid::Timestamps

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

  validates :state, :from_path, :to_path, :reason, :contact_email, :organisation_slug, :organisation_title, presence: true
  validates :from_path, :to_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
  validates :state, inclusion: { in: %w(pending accepted rejected) }, allow_blank: true

  before_validation :retreive_organisation_title, unless: ->{ organisation_title.present? }
  before_validation :strip_whitespace, :only => [:from_path, :to_path]

  scope :pending, -> { where(state: "pending") }

  def accept!
    new_short_url = Redirect.new(from_path: from_path, to_path: to_path, short_url_request: self)
    if new_short_url.save
      update_attributes state: 'accepted'
      Notifier.short_url_request_accepted(self).deliver
      true
    else
      false
    end
  end

  def update!
    short_url = self.redirect
    if short_url.update_attributes(to_path: to_path)
      true
    else
      false
    end
  end

  def reject!(reason = nil)
    update_attributes state: 'rejected',
                      rejection_reason: reason
    Notifier.short_url_request_rejected(self).deliver
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

  def strip_whitespace
    self.from_path = self.from_path.strip
    self.to_path = self.to_path.strip
  end
end
