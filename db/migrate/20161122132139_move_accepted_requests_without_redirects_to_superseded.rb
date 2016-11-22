class MoveAcceptedRequestsWithoutRedirectsToSuperseded < Mongoid::Migration
  class LocalRedirect
    include Mongoid::Document
    store_in collection: 'redirects'
    belongs_to :short_url_request, foreign_key: :short_url_request_id, class_name: 'MoveAcceptedRequestsWithoutRedirectsToSuperseded::LocalShortUrlRequest'
  end

  class LocalShortUrlRequest
    include Mongoid::Document
    store_in collection: 'short_url_requests'
    has_one :redirect, foreign_key: :short_url_request_id, class_name: 'MoveAcceptedRequestsWithoutRedirectsToSuperseded::LocalRedirect'
    field :state, type: String
  end

  def self.up
    LocalShortUrlRequest.where(state: 'accepted').each do |request|
      request.update_attributes(state: 'superseded') if request.redirect.nil?
    end
  end

  def self.down
    LocalShortUrlRequest.where(state: 'superseded').each do |request|
      request.update_attributes(state: 'accepted') if request.redirect.nil?
    end
  end
end
