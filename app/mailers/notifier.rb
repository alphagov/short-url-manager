class Notifier < ActionMailer::Base
  default from: "<Friendly URL manager> noreply+furl-manager@digital.cabinet-office.gov.uk"

  def furl_requested(furl_request)
    @furl_request = furl_request
    to = User.furl_managers.map &:email
    subject = "Furl request for '#{furl_request.from}' by #{furl_request.organisation_title}"
    mail to: to, subject: subject
  end
end
