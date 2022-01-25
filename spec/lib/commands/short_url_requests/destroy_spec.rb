require "rails_helper"

describe Commands::ShortUrlRequests::Destroy do
  let(:url_request) { create(:short_url_request, :accepted, from_path: "/deletable-url") }
  let(:other_url_request) { create(:short_url_request, :accepted, from_path: "/undeletable-url") }
  subject(:command) { described_class.new(url_request) }
  let(:success) { double(:success, call: true) }
  let(:failure) { double(:failure, call: true) }

  context "with a deletable short url" do
    it "deletes the record" do
      command.call(success: success, failure: failure)
      expect(ShortUrlRequest.all).to eq([other_url_request])
    end

    it "deletes the redirect" do
      command.call(success: success, failure: failure)
      expect(Redirect.all).to eq([other_url_request.redirect])
    end

    it "calls the success callback" do
      command.call(success: success, failure: failure)
      expect(success).to have_received(:call).once
    end
  end

  context "when deletion fails" do
    let(:undeletable_url_req) do
      double(ShortUrlRequest, destroy: false)
    end
    subject(:command) { described_class.new(undeletable_url_req) }

    it "does not delete the url" do
      command.call(success: success, failure: failure)

      expect(ShortUrlRequest.all).to eq([url_request, other_url_request])
    end

    it "does not delete the redirect" do
      command.call(success: success, failure: failure)

      expect(Redirect.all).to eq([url_request.redirect, other_url_request.redirect])
    end

    it "calls the failure callback" do
      command.call(success: success, failure: failure)

      expect(failure).to have_received(:call).once
    end
  end
end
