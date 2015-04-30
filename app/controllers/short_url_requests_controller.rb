class ShortUrlRequestsController < ApplicationController
  before_filter :authorise_as_short_url_requester!, only: [:new, :create]
  before_filter :authorise_as_short_url_manager!, only: [:index, :show, :accept, :new_rejection, :reject, :list_short_urls]
  before_filter :get_short_url_request, only: [:show, :accept, :new_rejection, :reject]

  def index
    @short_url_requests = ShortUrlRequest.pending.order_by([:created_at, 'desc']).paginate(page: (params[:page]), per_page: 40)
  end

  def show
  end

  def list_short_urls
    @accepted_short_urls = ShortUrlRequest.all.where(state: 'accepted').order_by([:created_at, 'desc'])
  end

  def new
    @short_url_request = ShortUrlRequest.new(organisation_slug: current_user.organisation_slug)
  end

  def create
    @short_url_request = ShortUrlRequest.new(create_short_url_request_params)
    @short_url_request.requester = current_user
    @short_url_request.contact_email = current_user.email

    if @short_url_request.save
      Notifier.short_url_requested(@short_url_request).deliver
      flash[:success] = "Your request has been made."
      redirect_to root_path
    else
      render 'new'
    end
  end

  def accept
    if !@short_url_request.accept!
      render template: 'short_url_requests/accept_failed'
    end
  end

  def new_rejection
  end

  def reject
    if @short_url_request.reject!(params[:short_url_request].try(:[], :rejection_reason))
      flash[:success] = "The short URL request has been rejected, and the requester has been notified."
    else
      flash[:error] = "The short URL request could not be rejected."
    end
    redirect_to short_url_requests_path
  end

  def organisations
    @organisations ||= Organisation.all.order_by([:title, 'asc'])
  end
  helper_method :organisations

private
  def get_short_url_request
    @short_url_request = ShortUrlRequest.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render text: "Not found", status: 404
  end

  def create_short_url_request_params
    @create_short_url_request_params ||= params[:short_url_request].permit(:from_path, :to_path, :reason, :organisation_slug)
  end
end
