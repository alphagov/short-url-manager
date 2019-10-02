require "rails_helper"

describe Commands::ShortUrlRequests::Reject do
  let(:url_request) { create(:short_url_request) }
  let(:reason) { "You weren't lucky today." }
  subject(:command) { described_class.new(url_request, reason) }

  it "rejects the request" do
    command.call

    expect(url_request.state).to eq("rejected")
    expect(url_request.rejection_reason).to eq(reason)
  end

  it "sends a rejection email" do
    allow(Notifier).to receive(:short_url_request_rejected).and_call_original

    command.call

    expect(Notifier).to have_received(:short_url_request_rejected).once.with(url_request)
  end
end
