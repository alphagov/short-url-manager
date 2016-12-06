require 'rails_helper'

describe ShortUrlRequest do
  include PublishingApiHelper

  include_examples "ShortUrlValidations", :short_url_request

  describe "validations:" do
    specify { expect(build :short_url_request).to be_valid }
    specify { expect(build :short_url_request, reason: '').to_not be_valid }
    specify { expect(build :short_url_request, organisation_title: '').to_not be_valid }
    specify { expect(build :short_url_request, organisation_slug: '').to_not be_valid }

    it "should allow 'pending', 'accepted', 'rejected', and 'superseded' as acceptable state values" do
      expect(build :short_url_request, state: 'pending').to be_valid
      expect(build :short_url_request, state: 'accepted').to be_valid
      expect(build :short_url_request, state: 'rejected').to be_valid
      expect(build :short_url_request, state: 'superseded').to be_valid
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
    describe ".pending" do
      context "with short_url_requests in different states" do
        let!(:pending_short_url_request) { create(:short_url_request, :pending) }
        let!(:accepted_short_url_request) { create(:short_url_request, :accepted) }
        let!(:rejected_short_url_request) { create(:short_url_request, :rejected) }
        let!(:superseded_short_url_request) { create(:short_url_request, :superseded) }

        it "should only include pending requests" do
          expect(ShortUrlRequest.pending).to be == [pending_short_url_request]
        end
      end
    end

    describe ".accepted" do
      context "with short_url_requests in different states" do
        let!(:pending_short_url_request) { create(:short_url_request, :pending) }
        let!(:accepted_short_url_request) { create(:short_url_request, :accepted) }
        let!(:rejected_short_url_request) { create(:short_url_request, :rejected) }
        let!(:superseded_short_url_request) { create(:short_url_request, :superseded) }

        it "should only include accepted requests" do
          expect(ShortUrlRequest.accepted).to be == [accepted_short_url_request]
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

    specify { expect(build(:short_url_request, state: 'superseded').superseded?).to be true }
    specify { expect(build(:short_url_request, state: 'accepted').superseded?).to be false }
  end

  describe '#similar_requests' do
    let(:from_path) { '/my-short-path' }
    let(:subject) { create(:short_url_request, from_path: from_path, to_path: '/a/long-version/of/my-short-path') }

    it 'includes other requests for the same from_path' do
      same_from_path = create(:short_url_request, from_path: from_path, to_path: '/a/different-place')
      expect(subject.similar_requests).to include same_from_path
    end

    it 'does not include other requests for the a different from_path' do
      different_from_path = create(:short_url_request, from_path: '/a-different-path', to_path: '/a/long-version/of/a-different-path')
      expect(subject.similar_requests).not_to include different_from_path
    end

    it 'does not include itself' do
      expect(subject.similar_requests).not_to include subject
    end

    it 'does not include other requests with the same to_path' do
      same_to_path = create(:short_url_request, from_path: '/a-different-path', to_path: subject.to_path)
      expect(subject.similar_requests).not_to include same_to_path
    end

    it 'includes other requests in creation order, oldest first' do
      duplicate_1 = create(:short_url_request, from_path: from_path, to_path: '/a/different-place', created_at: 5.days.ago)
      duplicate_2 = create(:short_url_request, from_path: from_path, to_path: '/a/different-place', created_at: 10.days.ago)
      duplicate_3 = create(:short_url_request, from_path: from_path, to_path: '/a/different-place', created_at: 8.days.ago)

      expect(subject.similar_requests).to eq [duplicate_2, duplicate_3, duplicate_1]
    end
  end
end
