class Commands::ShortUrlRequests::Create
  def initialize(params, requester)
    @params = params
    @requester = requester
  end

  def call(success:, confirmation_required:, failure:)
    url_request = create_object(params, requester)

    if !url_request.valid?
      failure.call(url_request)
    elsif requires_confirmation?(url_request)
      confirmation_required.call(url_request)
    elsif url_request.save
      Notifier.short_url_requested(url_request).deliver_now
      success.call(url_request)
    else
      failure.call(url_request)
    end
  end

private

  attr_reader :params, :requester

  def create_object(params, requester)
    ShortUrlRequest.new(params).tap do |url_request|
      url_request.requester = requester
      url_request.contact_email = requester.email
    end
  end

  def requires_confirmation?(url_request)
    url_request.similar_redirects.any? && !url_request.confirmed
  end
end
