class Commands::ShortUrlRequests::Accept
  def initialize(url_request)
    @url_request = url_request
  end

  def call(failure:)
    redirect = Redirect.find_or_initialize_by(from_path: url_request.from_path)

    if redirect.update_attributes(to_path: url_request.to_path, short_url_request: url_request)
      url_request.update_attribute(:state, 'accepted')
      Notifier.short_url_request_accepted(url_request).deliver_now
    else
      failure.call
    end
  end

private
  attr_reader :url_request
end
