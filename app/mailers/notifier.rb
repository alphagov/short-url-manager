class Notifier < ActionMailer::Base
  add_template_helper UrlHelper
  default from: "<Friendly URL manager> noreply+furl-manager@digital.cabinet-office.gov.uk"

  def furl_requested(furl_request)
    @furl_request = furl_request
    to = User.furl_managers.map &:email
    subject = "Friendly URL request for '#{furl_request.from_path}' by #{furl_request.organisation_title}"
    mail to: to, subject: subject
  end

  def furl_request_accepted(furl_request)
    @furl_request = furl_request
    to = Array(furl_request.contact_email)
    subject = "Friendly URL request approved"
    mail to: to, subject: subject
  end

  def furl_request_rejected(furl_request)
    @furl_request = furl_request
    to = Array(furl_request.contact_email)
    subject = "Friendly URL request denied"
    mail to: to, subject: subject
  end
end
