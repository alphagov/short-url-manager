require 'rails_helper'

describe Commands::ShortUrlRequests::Accept do
  let(:url_request) { create(:short_url_request) }
  let(:failure) { double(:failure, call: true) }

  subject(:command) { described_class.new(url_request) }

  context "with a successful redirect creation" do
    it "results in an active redirect" do
      command.call(failure: failure)

      expect(url_request.redirect).not_to be_nil
      expect(url_request.redirect.attributes.slice(:from_path, :to_path)).to eq(url_request.attributes.slice(:from_path, :to_path))
    end

    it "changes request state to accepted" do
      command.call(failure: failure)

      expect(url_request).to be_accepted
    end
  end

  context "where an existing redirect already exists" do
    let!(:other_request) { create(:short_url_request, :accepted) }
    let(:url_request) { create(:short_url_request, from_path: other_request.from_path) }

    it "updates the existing redirect" do
      expect { command.call(failure: failure) }.to_not change(Redirect, :count)
    end

    it "changes the redirect association" do
      redirect = Redirect.find_by(from_path: other_request.from_path)
      expect(redirect.short_url_request).to eq(other_request)

      command.call(failure: failure)
      redirect.reload

      expect(redirect.short_url_request).to eq(url_request)
    end

    it "marks the existing request as superseded" do
      command.call(failure: failure)
      other_request.reload

      expect(other_request).to be_superseded
    end

    it "marks the new request as accepted" do
      command.call(failure: failure)
      url_request.reload

      expect(url_request).to be_accepted
    end
  end
end
