require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe DashboardController do
  let(:user) { create(:short_url_requester_and_manager) }
  before { login_as user }
  it "renders the application layout" do
    get :dashboard
    expect(response).to render_template "application"
  end
end
