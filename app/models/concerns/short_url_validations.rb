module ShortUrlValidations
  extend ActiveSupport::Concern

  included do
    validates :from_path, :to_path, presence: true
    validates :from_path, :to_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
  end
end
