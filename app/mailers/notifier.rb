class Notifier < ApplicationMailer
  add_template_helper UrlHelper
  default from: '"Short URL manager" <noreply+short-url-manager@digital.cabinet-office.gov.uk>'

  def short_url_requested(short_url_request, recipients)
    subject = "#{prefix}Short URL request for '#{short_url_request.from_path}' by #{short_url_request.organisation_title}"
    send_mail(recipients, subject, short_url_request)
  end

  def short_url_request_accepted(short_url_request, recipients)
    subject = "#{prefix}Short URL request approved"
    send_mail(recipients, subject, short_url_request)
  end

  def short_url_request_rejected(short_url_request, recipients)
    subject = "#{prefix}Short URL request denied"
    send_mail(recipients, subject, short_url_request)
  end

private

  attr_reader :short_url_request

  def send_mail(to, subject, short_url_request)
    @short_url_request = short_url_request
    mail to: to, subject: subject
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
