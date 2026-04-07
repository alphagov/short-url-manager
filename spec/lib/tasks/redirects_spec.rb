require "rails_helper"
require "rake"
require "thor"

describe "redirects" do
  include GdsApi::TestHelpers::PublishingApi
  include PublishingApiHelper

  before :all do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require("lib/tasks/redirects", [Rails.root.to_s])
  end

  before :each do
    task.reenable
  end

  let!(:organisation) { create(:organisation, slug: "government-digital-service") }
  let(:task) { Rake::Task["redirects:create_and_apply"] }
  let(:task_arguments) do
    [
      "a@gov.uk",
      "/from-path",
      "/to-path",
      "Manual redirect needed as not supported in publishing app",
      "true", # override existing redirect if it exists
      "exact", # or "prefix"
      "ignore", # or "preserve"
      "government-digital-service",
      "Government Digital Service",
    ]
  end

  it "creates and applies the redirect" do
    allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
    task.invoke(*task_arguments)

    request = ShortUrlRequest.last

    expect(request).to have_attributes(
      from_path: "/from-path",
      to_path: "/to-path",
      state: "accepted",
    )
    assert_publishing_api_put_content(
      request.redirect.content_id,
      publishing_api_redirect_hash(
        "/from-path",
        "/to-path",
        "exact",
        "ignore",
      ),
    )
    assert_publishing_api_publish(
      request.redirect.content_id,
      nil,
      1,
    )
  end

  context "when the user aborts" do
    before do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(false)
    end

    it "does not create a redirect" do
      task.invoke(*task_arguments)
      expect(ShortUrlRequest.count).to eq(0)
    end
  end
end
