require "rails_helper"

RSpec.describe ShortUrlRequestDataComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:short_url_request) { create(:short_url_request) }

  it "renders the short URL request details" do
    render_inline(described_class.new(short_url_request:))

    expect(rendered_content).to include(short_url_request.organisation_title)
    expect(rendered_content).to include(short_url_request.from_path)
    expect(rendered_content).to include(short_url_request.to_path)
    expect(rendered_content).to include(short_url_request.reason)
    expect(rendered_content).to include(short_url_request.contact_email)
    expect(rendered_content).to include("State")
  end

  it "renders the from path when show_short_url is true" do
    render_inline(
      described_class.new(
        short_url_request:,
        show_short_url: true,
      ),
    )

    expect(rendered_content).to include("URL redirect or short URL")
    expect(rendered_content).to include(short_url_request.from_path)
  end

  it "does not render the from path when show_short_url is false" do
    render_inline(
      described_class.new(
        short_url_request:,
        show_short_url: false,
      ),
    )

    expect(rendered_content).not_to include("URL redirect or short URL")
  end
end
