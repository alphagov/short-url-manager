require "rails_helper"

describe Commands::ShortUrlRequests::Reject do
  let(:url_request) { create(:short_url_request) }
  let(:reason) { "You weren't lucky today." }
  subject(:command) { described_class.new(url_request, reason) }
  let(:user_email) { Array(url_request.contact_email) }

  it "rejects the request" do
    command.call

    expect(url_request.state).to eq("rejected")
    expect(url_request.rejection_reason).to eq(reason)
  end

  it "sends a rejection email" do
    allow(RequestNotifier).to receive(:email).and_call_original

    command.call

    expect(RequestNotifier).to have_received(:email).once.with(:short_url_request_rejected, url_request)
  end
end
