class Commands::ShortUrlRequests::Accept
  def initialize(url_request)
    @url_request = url_request
  end

  def call(failure:)
    redirect = Redirect.find_or_initialize_by(from_path: url_request.from_path)
    # NOTE: we get the target of the relation because otherwise we are holding
    # a proxy object that will update after we set the url_request in the
    # update_attributes call below
    # NOTE 2: this looks like it could be replaced with `.try(:target)` but it
    # can't as the tests fail - seems the `try` version still retains a proxy
    existing_request = redirect.short_url_request.nil? ? nil : redirect.short_url_request.target

    if redirect.update_attributes(to_path: url_request.to_path, short_url_request: url_request)
      url_request.update_attribute(:state, 'accepted')
      existing_request.update_attribute(:state, 'superseded') if existing_request.present?
      Notifier.short_url_request_accepted(url_request).deliver_now
    else
      failure.call
    end
  end

private
  attr_reader :url_request
end
