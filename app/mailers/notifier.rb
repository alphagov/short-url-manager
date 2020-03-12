class Notifier < ApplicationMailer
  add_template_helper UrlHelper
  default from: '"Short URL manager" <noreply+short-url-manager@digital.cabinet-office.gov.uk>'

  def short_url_requested(short_url_request, recipient)
    @short_url_request = short_url_request
    subject = "#{prefix}Short URL request for '#{short_url_request.from_path}' by #{short_url_request.organisation_title}"
    view_mail(template_id, to: recipient, subject: subject)
  end

  def short_url_request_accepted(short_url_request, recipient)
    @short_url_request = short_url_request
    subject = "#{prefix}Short URL request approved"
    view_mail(template_id, to: recipient, subject: subject)
  end

  def short_url_request_rejected(short_url_request, recipient)
    @short_url_request = short_url_request
    subject = "#{prefix}Short URL request denied"
    view_mail(template_id, to: recipient, subject: subject)
  end

private

  attr_reader :short_url_request

  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end

  def prefix
    "[#{Rails.application.config.instance_name}] " unless production?
  end

  def production?
    # We don't set this on the production environment, but we do on all
    # others (dev VM, test, integration, staging)
    Rails.application.config.instance_name.blank?
  end
end
