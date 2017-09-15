class Notifier < ActionMailer::Base
  add_template_helper UrlHelper
  default from: '"Short URL manager" <noreply+short-url-manager@digital.cabinet-office.gov.uk>'

  def short_url_requested(short_url_request)
    @short_url_request = short_url_request
    to = User.notification_recipients.map(&:email)
    subject = "#{prefix}Short URL request for '#{short_url_request.from_path}' by #{short_url_request.organisation_title}"
    mail to: to, subject: subject
  end

  def short_url_request_accepted(short_url_request)
    @short_url_request = short_url_request
    to = Array(short_url_request.contact_email)
    subject = "#{prefix}Short URL request approved"
    mail to: to, subject: subject
  end

  def short_url_request_rejected(short_url_request)
    @short_url_request = short_url_request
    to = Array(short_url_request.contact_email)
    subject = "#{prefix}Short URL request denied"
    mail to: to, subject: subject
  end

private

  def prefix
    "[#{Rails.application.config.instance_name}] " unless production?
  end

  def production?
    # We don't set this on the production environment, but we do on all
    # others (dev VM, test, integration, staging)
    Rails.application.config.instance_name.blank?
  end
end
