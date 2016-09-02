require 'rails_helper'

describe Commands::ShortUrlRequests::Update do
  let!(:url_request) { create(:short_url_request, :accepted, from_path: "/the-original-url") }
  subject(:command) { described_class.new(params, url_request) }
  let(:success) { double(:success, call: true) }
  let(:failure) { double(:failure, call: true) }

  context "with valid data" do
    let(:params) {
      {
        from_path: "/a-friendly-url",
        to_path: "/somewhere/a-document",
        reason: "Because wombles",
      }
    }

    it "updates the record" do
      command.call(success: success, failure: failure)

      expect(ShortUrlRequest.last.from_path).to eq("/a-friendly-url")
    end

    it "calls the success callback" do
      command.call(success: success, failure: failure)

      expect(success).to have_received(:call).once
    end

    it "updates the redirect" do
      command.call(success: success, failure: failure)

      expect { Redirect.find_by(from_path: "/a-friendly-url") }.not_to raise_error
    end
  end

  context "with invalid data" do
    let(:params) {
      {
        from_path: "",
        to_path: "",
        reason: "Because wombles",
      }
    }

    it "calls the failure callback" do
      command.call(success: success, failure: failure)

      expect(failure).to have_received(:call).once
    end
  end
end
