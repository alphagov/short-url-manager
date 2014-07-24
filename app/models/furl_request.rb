class FurlRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: String
  field :to, type: String
  field :reason, type: String
  field :contact_email, type: String

  belongs_to :requester, class_name: "User"

  validates :from, :to, :reason, presence: true
  validates :contact_email, presence: true, format: { with: /\A[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})\z/ }
end
