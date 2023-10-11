module ShortUrlValidations
  extend ActiveSupport::Concern

  # Ideally this should be kept up to date with the corresponding list in the publishing API
  # https://github.com/alphagov/publishing-api/blob/main/app/validators/routes_and_redirects_validator.rb#L2-L10
  EXTERNAL_HOST_ALLOW_LIST = %w[
    .caa.co.uk
    .gov.uk
    .judiciary.uk
    .moneyhelper.org.uk
    .nationalhighways.co.uk
    .nhs.uk
    .police.uk
    .ukri.org
  ].freeze

  included do
    validates :from_path, :to_path, presence: true
    validates :from_path, format: { with: /\A\//, message: 'must be specified as a relative path (eg. "/hmrc/tax-returns")' }, allow_blank: true
    validate :to_path_is_valid
  end

  def to_path_is_valid
    unless to_path.blank? || to_path =~ /\A\// || allowed_government_absolute_url?(to_path)
      errors.add(:to_path, "must be a relative path (eg. /hmrc/tax-returns) or a government URL (eg. #{ShortUrlValidations.allow_host_display_list})")
    end
  end

  def allowed_government_absolute_url?(path)
    uri = URI.parse(path)
    uri.scheme == "https" && uri.host.end_with?(*EXTERNAL_HOST_ALLOW_LIST) && uri.host != "www.gov.uk"
  rescue StandardError
    false
  end

  def self.allow_host_display_list
    EXTERNAL_HOST_ALLOW_LIST.map { |host| "*#{host}" }.join(", ")
  end
end
