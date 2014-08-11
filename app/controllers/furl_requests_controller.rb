class FurlRequestsController < ApplicationController
  before_filter :authorise_as_furl_requester!, only: [:new, :create]
  before_filter :authorise_as_furl_manager!, only: [:index, :show]

  def index
    @furl_requests = FurlRequest.order_by([:created_at, 'desc']).paginate(page: (params[:page]), per_page: 40)
  end

  def show
    @furl_request = FurlRequest.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render text: "Not found", status: 404
  end

  def new
    @furl_request = FurlRequest.new(contact_email: current_user.email, organisation_slug: current_user.organisation_slug)
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

  def authorise_as_furl_requester!
    authorise_user!('request_furls')
  end

  def authorise_as_furl_manager!
    authorise_user!('manage_furls')
  end
end
