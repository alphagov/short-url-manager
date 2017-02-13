class Commands::ShortUrlRequests::Update
  def initialize(params, url_request)
    @params = params
    @url_request = url_request
  end

  def call(success:, failure:)
    if url_request.update_attributes(params)
      if url_request.redirect.present?
        url_request.redirect.update_attributes(
          from_path: url_request.from_path,
          to_path: url_request.to_path,
        )
      end

      success.call
    else
      failure.call
    end
  end

private

  attr_reader :params, :url_request
end
