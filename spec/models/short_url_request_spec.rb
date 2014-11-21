require 'rails_helper'

describe ShortUrlRequest do
  describe "validations:" do
    specify { expect(build :short_url_request).to be_valid }
    specify { expect(build :short_url_request, from_path: '').to_not be_valid }
    specify { expect(build :short_url_request, to_path: '').to_not be_valid }
    specify { expect(build :short_url_request, reason: '').to_not be_valid }
    specify { expect(build :short_url_request, contact_email: '').to_not be_valid }
    specify { expect(build :short_url_request, contact_email: 'invalid.email.address').to_not be_valid }
    specify { expect(build :short_url_request, organisation_title: '').to_not be_valid }
    specify { expect(build :short_url_request, organisation_slug: '').to_not be_valid }

    it "should be invalid when from_path is not a relative path" do
      expect(build :short_url_request, from_path: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when to_path is not a relative path" do
      expect(build :short_url_request, to_path: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when contact_email is not a valid email address" do
      expect(build :short_url_request, contact_email: 'invalid.email.address').to_not be_valid
    end

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

  describe "state changes" do
    let(:stub_mail) { double }
    def stub_notification(type)
      allow(stub_mail).to receive(:deliver)
      allow(Notifier).to receive(type).and_return(stub_mail)
    end

    let(:short_url_request) { create :short_url_request, :pending }

    describe "accept!" do
      let(:redirect_creation_successful?) { true }
      let(:new_short_url) {
        new_short_url = double
        allow(new_short_url).to receive(:save).and_return(redirect_creation_successful?)
        new_short_url
      }
      before {
        stub_notification(:short_url_request_accepted)
        allow(Redirect).to receive(:new).and_return(new_short_url)
      }
      let!(:return_value) { short_url_request.accept! }

      it "should create a related Redirect, copying :to_path and :from_path attributes" do
        expect(Redirect).to have_received(:new).with(hash_including(to_path: short_url_request.to_path, from_path: short_url_request.from_path))
        expect(new_short_url).to have_received(:save)
      end

      it "should return true, indicating that the state change was successful" do
        expect(return_value).to equal true
      end

      it "should have set the state to 'accepted'" do
        expect(short_url_request.reload.state).to eql 'accepted'
      end

      it "should have sent a notification" do
        expect(Notifier).to have_received(:short_url_request_accepted).with(short_url_request)
        expect(stub_mail).to have_received(:deliver)
      end

      context "when the redirect can't be created for some reason" do
        let(:redirect_creation_successful?) { false }

        it "should not have updated the state" do
          expect(short_url_request.state).to eql 'pending'
        end

        it "should return false, indicating that the state change wasn't successful" do
          expect(return_value).to eql false
        end

        it "should not have sent a notification" do
          expect(Notifier).to_not have_received(:short_url_request_accepted)
        end
      end
    end

    describe "reject!" do
      before { stub_notification(:short_url_request_rejected) }

      it "should set the state to rejected, and store the given reason" do
        short_url_request.reject!("A reason")
        short_url_request.reload

        expect(short_url_request.state).to eql "rejected"
        expect(short_url_request.rejection_reason).to eql "A reason"
      end

      it "should return true, indicating that the state chage was successful" do
        expect(short_url_request.reject!).to equal true
      end

      it "should have sent a notification" do
        short_url_request.reject!

        expect(Notifier).to have_received(:short_url_request_rejected).with(short_url_request)
        expect(stub_mail).to have_received(:deliver)
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
end
