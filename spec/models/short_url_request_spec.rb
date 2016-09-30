require 'rails_helper'

describe ShortUrlRequest do
  include PublishingApiHelper

  include_examples "ShortUrlValidations", :short_url_request

  describe "validations:" do
    specify { expect(build :short_url_request).to be_valid }
    specify { expect(build :short_url_request, reason: '').to_not be_valid }
    specify { expect(build :short_url_request, organisation_title: '').to_not be_valid }
    specify { expect(build :short_url_request, organisation_slug: '').to_not be_valid }

    it "should allow 'pending', 'accepted' and 'rejected' as acceptable state values" do
      expect(build :short_url_request, state: 'pending').to be_valid
      expect(build :short_url_request, state: 'accepted').to be_valid
      expect(build :short_url_request, state: 'rejected').to be_valid
      expect(build :short_url_request, state: 'liquid').to_not be_valid
    end

    it "should trim whitespace from from_path and to_path" do
      from_path_stripped_whitespace = create(:short_url_request, from_path: '/a-path ')
      to_path_stripped_whitespace = create(:short_url_request, to_path: '/b-path ')
      expect(from_path_stripped_whitespace.from_path).to eq('/a-path')
      expect(to_path_stripped_whitespace.to_path).to eq('/b-path')
    end

    context "with a pre-existing redirect" do
      before { create(:redirect, from_path: '/a-path', to_path: '/b-path') }

      it "is invalid" do
        expect(build :short_url_request, from_path: '/a-path', to_path: '/b-path').not_to be_valid
      end
    end
  end

  describe "scopes" do
    describe "pending" do
      context "with short_url_requests in different states" do
        let!(:pending_short_url_request) { create(:short_url_request, :pending) }
        let!(:accepted_short_url_request) { create(:short_url_request, :accepted) }
        let!(:rejected_short_url_request) { create(:short_url_request, :rejected) }

        it "should only include pending requests" do
          expect(ShortUrlRequest.pending).to be == [pending_short_url_request]
        end
      end
    end
  end

  describe "organisation fields" do
    context "when an organisation slug for an existing organisation is given" do
      let!(:organisation) { create :organisation }
      let(:instance) { build :short_url_request, organisation_slug: organisation.slug,
                                                 organisation_title: organisation.title
      }

      it "should set organisation_title to that of the organisation before validating" do
        expect(instance).to be_valid
        expect(instance.organisation_title).to eql organisation.title
      end
    end
  end

  describe "boolean convienience methods" do
    specify { expect(build(:short_url_request, state: 'pending').pending?).to be true }
    specify { expect(build(:short_url_request, state: 'accepted').pending?).to be false }

    specify { expect(build(:short_url_request, state: 'accepted').accepted?).to be true }
    specify { expect(build(:short_url_request, state: 'rejected').accepted?).to be false }

    specify { expect(build(:short_url_request, state: 'rejected').rejected?).to be true }
    specify { expect(build(:short_url_request, state: 'accepted').rejected?).to be false }
  end
end
