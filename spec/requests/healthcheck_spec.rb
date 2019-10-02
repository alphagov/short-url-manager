require "rails_helper"

describe "the healthcheck page" do
  it "should return success" do
    get "/healthcheck"

    expect(response.status).to eq(200)
  end
end
