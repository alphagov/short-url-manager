class FurlRequestsController < ApplicationController
  def new
    @furl_request = FurlRequest.new
  end

  def create
    @furl_request = FurlRequest.new(furl_request_params)
    if @furl_request.save
      flash[:success] = "Your request has been made."
      redirect_to root_path
    else
      render 'new'
    end
  end

private
  def furl_request_params
    params[:furl_request].permit(:from, :to, :reason, :contact_email)
  end
end
