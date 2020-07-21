class Commands::ShortUrlRequests::Reject
  def initialize(url_request, reason = nil)
    @url_request = url_request
    @reason = reason
  end

  def call
    url_request.update!(state: "rejected", rejection_reason: reason)
    RequestNotifier.email(:short_url_request_rejected, url_request).each(&:deliver_later)
  end

private

  attr_reader :url_request, :reason
end
