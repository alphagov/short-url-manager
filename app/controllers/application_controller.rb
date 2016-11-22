class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!

private
  def authorise_as_short_url_requester!
    authorise_user!('request_short_urls')
  end

  def authorise_as_short_url_manager!
    authorise_user!('manage_short_urls')
  end
end
