class FurlRequestsController < ApplicationController
  before_filter :authourise_as_furl_requester!, only: [:new, :create]

  def new
    @furl_request = FurlRequest.new(organisation_slug: current_user.organisation_slug)
  end

  def create
    @furl_request = FurlRequest.new(furl_request_params)
    @furl_request.requester = current_user

    if @furl_request.save
      Notifier.furl_requested(@furl_request).deliver
      flash[:success] = "Your request has been made."
      redirect_to root_path
    else
      render 'new'
    end
  end

  def organisations
    @organisations ||= Organisation.all.order_by([:title, 'asc'])
  end
  helper_method :organisations

private
  def furl_request_params
    @furl_request_params ||= params[:furl_request].permit(:from, :to, :reason, :contact_email, :organisation_slug)
  end

  def authourise_as_furl_requester!
    authorise_user!('request_furls')
  end
end
