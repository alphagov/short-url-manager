class Commands::ShortUrlRequests::Reject
  def initialize(url_request, reason=nil)
    @url_request = url_request
    @reason = reason
  end

  def call
    url_request.update_attributes(state: 'rejected', rejection_reason: reason)
    Notifier.short_url_request_rejected(url_request).deliver_now
  end

private
  attr_reader :url_request, :reason
end
