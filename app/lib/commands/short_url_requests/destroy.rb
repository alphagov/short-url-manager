class Commands::ShortUrlRequests::Destroy
  def initialize(short_url)
    @short_url = short_url
  end

  def call(success:, failure:)
    if short_url.destroy
      success.call
    else
      failure.call
    end
  end

private

  attr_reader :short_url
end
