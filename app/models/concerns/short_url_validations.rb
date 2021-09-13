module ShortUrlValidations
  extend ActiveSupport::Concern

  included do
    validates :from_path, :to_path, presence: true
    validates :from_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
    validate :to_path_is_valid
  end

  def to_path_is_valid
    unless to_path.blank? || to_path =~ /\A\// || allowed_government_absolute_url?(to_path)
      errors.add(:to_path, 'must be a relative path (eg. "/hmrc/tax-returns") or a government URL (eg. *.gov.uk, *.judiciary.uk, *.nhs.uk, *.ukri.org)')
    end
  end

  def allowed_government_absolute_url?(path)
    uri = URI.parse(path)
    uri.scheme == "https" && uri.host.end_with?(".gov.uk", ".judiciary.uk", ".nhs.uk", ".ukri.org") && uri.host != "www.gov.uk"
  rescue StandardError
    false
  end
end
