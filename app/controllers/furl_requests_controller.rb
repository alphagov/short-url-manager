class FurlRequestsController < ApplicationController
  before_filter :authorise_as_furl_requester!, only: [:new, :create]
  before_filter :authorise_as_furl_manager!, only: [:index, :show, :accept, :new_rejection, :reject]
  before_filter :get_furl_request, only: [:show, :accept, :new_rejection, :reject]

  def index
    @furl_requests = FurlRequest.order_by([:created_at, 'desc']).paginate(page: (params[:page]), per_page: 40)
  end

  def show
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

  def accept
    @furl = Furl.new from: @furl_request.from,
                     to: @furl_request.to,
                     request: @furl_request
    if @furl.save
      Notifier.furl_request_accepted(@furl_request).deliver
    end
  end

  def new_rejection
  end

  def reject
    @furl_request.update_attribute(:rejection_reason, params[:furl_request].try(:[], :rejection_reason))
    Notifier.furl_request_rejected(@furl_request).deliver
    flash[:success] = "The friendly URL request has been rejected, and the requester has been notified."
    redirect_to furl_requests_path
  end

  def organisations
    @organisations ||= Organisation.all.order_by([:title, 'asc'])
  end
  helper_method :organisations

private
  def get_furl_request
    @furl_request = FurlRequest.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render text: "Not found", status: 404
  end

  def furl_request_params
    @furl_request_params ||= params[:furl_request].permit(:from, :to, :reason, :contact_email, :organisation_slug)
  end
end
