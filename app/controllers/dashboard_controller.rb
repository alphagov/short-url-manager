class DashboardController < ApplicationController
  def dashboard
    render layout: "design_system" if Rails.env.development?
  end
end
