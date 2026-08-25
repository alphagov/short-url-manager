# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestStatusComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders a green tag for an accepted request" do
    short_url_request = create(:short_url_request, :accepted)
    component = described_class.new(short_url_request)

    allow(component).to receive(:render).and_call_original
    render_inline(component)

    expect(component).to have_received(:render).with(
      "govuk_publishing_components/components/tag",
      hash_including(colour: "green"),
    )
    expect(page).to have_text("Accepted")
  end

  it "renders a blue tag for a pending request" do
    short_url_request = create(:short_url_request, :pending)
    component = described_class.new(short_url_request)

    allow(component).to receive(:render).and_call_original
    render_inline(component)

    expect(component).to have_received(:render).with(
      "govuk_publishing_components/components/tag",
      hash_including(colour: "blue"),
    )
    expect(page).to have_text("Pending")
  end

  it "renders a red tag for a rejected request" do
    short_url_request = create(:short_url_request, :rejected)
    component = described_class.new(short_url_request)

    allow(component).to receive(:render).and_call_original
    render_inline(component)

    expect(component).to have_received(:render).with(
      "govuk_publishing_components/components/tag",
      hash_including(colour: "red"),
    )
    expect(page).to have_text("Rejected")
  end

  it "renders a grey tag for a superseded request" do
    short_url_request = create(:short_url_request, :superseded)
    component = described_class.new(short_url_request)

    allow(component).to receive(:render).and_call_original
    render_inline(component)

    expect(component).to have_received(:render).with(
      "govuk_publishing_components/components/tag",
      hash_including(colour: "grey"),
    )
    expect(page).to have_text("Superseded")
  end
end
