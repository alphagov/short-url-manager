require 'rails_helper'

describe FurlRequest do
  describe "validations:" do
    specify { expect(build :furl_request).to be_valid }
    specify { expect(build :furl_request, from: '').to_not be_valid }
    specify { expect(build :furl_request, to: '').to_not be_valid }
    specify { expect(build :furl_request, reason: '').to_not be_valid }
    specify { expect(build :furl_request, contact_email: '').to_not be_valid }
    specify { expect(build :furl_request, contact_email: 'invalid.email.address').to_not be_valid }
    specify { expect(build :furl_request, organisation_title: '').to_not be_valid }
    specify { expect(build :furl_request, organisation_slug: '').to_not be_valid }

    it "should be invalid when from is not a relative path" do
      expect(build :furl_request, from: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when to is not a relative path" do
      expect(build :furl_request, to: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when contact_email is not a valid email address" do
      expect(build :furl_request, contact_email: 'invalid.email.address').to_not be_valid
    end

    it "should allow 'pending', 'accepted' and 'rejected' as acceptable state values" do
      expect(build :furl_request, state: 'pending').to be_valid
      expect(build :furl_request, state: 'accepted').to be_valid
      expect(build :furl_request, state: 'rejected').to be_valid
      expect(build :furl_request, state: 'liquid').to_not be_valid
    end
  end

  describe "organisation fields" do
    context "when an organisation slug for an existing organisation is given" do
      let!(:organisation) { create :organisation }
      let(:instance) { build :furl_request, organisation_slug: organisation.slug,
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

    let(:furl_request) { create :furl_request, :pending }

    describe "accept!" do
      let(:furl_creation_successful?) { true }
      let(:new_furl) {
        new_furl = double
        allow(new_furl).to receive(:save).and_return(furl_creation_successful?)
        new_furl
      }
      before {
        stub_notification(:furl_request_accepted)
        allow(Furl).to receive(:new).and_return(new_furl)
      }
      let!(:return_value) { furl_request.accept! }

      it "should create a related Furl, copying :to and :from attributes" do
        expect(Furl).to have_received(:new).with(hash_including(to: furl_request.to, from: furl_request.from))
        expect(new_furl).to have_received(:save)
      end

      it "should return true, indicating that the state change was successful" do
        expect(return_value).to equal true
      end

      it "should have set the state to 'accepted'" do
        expect(furl_request.reload.state).to eql 'accepted'
      end

      it "should have sent a notification" do
        expect(Notifier).to have_received(:furl_request_accepted).with(furl_request)
        expect(stub_mail).to have_received(:deliver)
      end

      context "when the furl can't be created for some reason" do
        let(:furl_creation_successful?) { false }

        it "should not have updated the state" do
          expect(furl_request.state).to eql 'pending'
        end

        it "should return false, indicating that the state change wasn't successful" do
          expect(return_value).to eql false
        end

        it "should not have sent a notification" do
          expect(Notifier).to_not have_received(:furl_request_accepted)
        end
      end
    end

    describe "reject!" do
      before { stub_notification(:furl_request_rejected) }

      it "should set the state to rejected, and store the given reason" do
        furl_request.reject!("A reason")
        furl_request.reload

        expect(furl_request.state).to eql "rejected"
        expect(furl_request.rejection_reason).to eql "A reason"
      end

      it "should return true, indicating that the state chage was successful" do
        expect(furl_request.reject!).to equal true
      end

      it "should have sent a notification" do
        furl_request.reject!

        expect(Notifier).to have_received(:furl_request_rejected).with(furl_request)
        expect(stub_mail).to have_received(:deliver)
      end
    end

    describe "boolean convienience methods" do
      specify { expect(build(:furl_request, state: 'pending').pending?).to be true }
      specify { expect(build(:furl_request, state: 'accepted').pending?).to be false }

      specify { expect(build(:furl_request, state: 'accepted').accepted?).to be true }
      specify { expect(build(:furl_request, state: 'rejected').accepted?).to be false }

      specify { expect(build(:furl_request, state: 'rejected').rejected?).to be true }
      specify { expect(build(:furl_request, state: 'accepted').rejected?).to be false }
    end
  end
end
