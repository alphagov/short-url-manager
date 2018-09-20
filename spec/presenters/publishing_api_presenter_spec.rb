require "rails_helper"

RSpec.describe Presenters::PublishingAPI do
  let(:redirect) do
    FactoryBot.build(
      :redirect,
      from_path: "/from/path",
      to_path: "/to/path",
    )
  end

  it "presents the redirect for the publishing api" do
    presented = described_class.present(redirect)

    expect(presented).to eq(
      "base_path" => "/from/path",
      "schema_name" => "redirect",
      "document_type" => "redirect",
      "publishing_app" => "short-url-manager",
      "update_type" => "major",
      "redirects" => [
        { "path" => "/from/path", "type" => "exact", "segments_mode" => "ignore", "destination" => "/to/path" }
      ]
    )
  end

  it "validates successfully against the content schema" do
    presented = described_class.present(redirect)
    expect(presented).to be_valid_against_schema("redirect")
  end
end
