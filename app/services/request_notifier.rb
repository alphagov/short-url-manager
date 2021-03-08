class RequestNotifier
  # GOV.UK Notify sets a max of 1 recipient
  MAX_EMAIL_RECIPIENTS = 1

  def initialize(short_url_request:, mailer: Notifier)
    @mailer = mailer
    @short_url_request = short_url_request
  end

  def self.email(event, short_url_request, mailer: Notifier)
    recipients_for(event, short_url_request)
      .in_groups_of(MAX_EMAIL_RECIPIENTS, false)
      .map do |recipient_group|
        mailer.send(event, short_url_request, recipient_group)
      end
  rescue Notifications::Client::BadRequestError => e
    # in production we care about all errors
    # in staging and integration the team-only error is unrecoverable when running asynchronously
    # (team-only error is unrecoverable in production too, but almost certainly impossible)
    raise if ENV["SENTRY_CURRENT_ENV"] !~ /integration|staging/ || e.message !~ /team-only API key/
  end

  def self.recipients_for(event_category, short_url_request)
    if event_category == :short_url_requested
      User.notification_recipients.map(&:email)
    else
      Array(short_url_request.contact_email)
    end
  end
end
