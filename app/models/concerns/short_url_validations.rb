module ShortUrlValidations
  extend ActiveSupport::Concern

  included do
    validates :from_path, :to_path, presence: true
    validates :from_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
    validate :to_path_is_valid
  end

  def to_path_is_valid
    unless to_path.blank? || to_path =~ /\A\// || govuk_subdomain_url?(to_path)
      errors.add(:to_path, 'must be a relative path (eg. "/hmrc/tax-returns") or a gov.uk redirect URL (eg. "https://my-title.service.gov.uk/an-optional-path")')
    end
  end

  def govuk_subdomain_url?(path)
    uri = URI.parse(path)
    uri.host =~ /\A([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[A-Za-z0-9])?\.)*gov\.uk\z/i && uri.scheme == 'https'
  rescue
    false
  end
end
