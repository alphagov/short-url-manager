require "rails_helper"

RSpec.describe BreadcrumbsComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:root) do
    instance_double("Breadcrumb", text: "Dashboard", url: "/")
  end

  let(:index) do
    instance_double(
      "Breadcrumb",
      text: "URL redirect or short URL requests",
      url: "/short_url_requests",
    )
  end

  let(:current) do
    instance_double(
      "Breadcrumb",
      text: "View short URL request",
      url: "/short_url_requests/1",
    )
  end

  describe "rendering" do
    it "renders all but the current breadcrumb" do
      render_inline(described_class.new([root, index, current]))

      expect(rendered_content).to include("Dashboard")
      expect(rendered_content).to include("URL redirect or short URL requests")
      expect(rendered_content).to include('href="/"')
      expect(rendered_content).to include('href="/short_url_requests"')

      expect(rendered_content).not_to include("View short URL request")
      expect(rendered_content).not_to include('href="/short_url_requests/1"')
    end

    it "renders nothing when there is only one breadcrumb to display" do
      render_inline(described_class.new([root, current]))

      expect(rendered_content).to be_blank
    end

    it "renders nothing when there are no parent breadcrumbs" do
      render_inline(described_class.new([current]))

      expect(rendered_content).to be_blank
    end
  end
end
