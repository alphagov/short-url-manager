require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe FurlRequestsController do
  let(:user) { create(:user, permissions: ['signon', 'request_furls', 'manage_furls']) }
  before { login_as user }

  describe "access control" do
    context "with a user without request_furls permission" do
      let(:user) { create(:user, permissions: ['signon', 'manage_furls']) }

      specify {
        expect_not_authourised(:get, :new)
        expect_not_authourised(:post, :create)
      }
    end

    context "with a user without manage_furls permission" do
      let(:user) { create(:user, permissions: ['signon', 'request_furls']) }

      specify {
        expect_not_authourised(:get, :index)
        expect_not_authourised(:get, :show, id: 'required-param')
        expect_not_authourised(:post, :accept, id: 'required-param')
        expect_not_authourised(:get, :new_rejection, id: 'required-param')
        expect_not_authourised(:post, :reject, id: 'required-param')
      }
    end
  end

  describe "#index" do
    context "with several furl_requests requested at different times" do
      let!(:furl_requests) { [
        create(:furl_request, created_at: 10.days.ago),
        create(:furl_request, created_at: 5.days.ago),
        create(:furl_request, created_at: 15.days.ago)
      ] }
      before { get :index }

      it "should order furl_requests by created_at date with the most recent first" do
        expect(assigns[:furl_requests]).to be == [furl_requests[1], furl_requests[0], furl_requests[2]]
      end
    end

    context "with 45 furl requests" do
      let!(:furl_requests) { 45.times.map { |n| create :furl_request, created_at: n.days.ago } }
      before { get :index, params }

      context "page param is not given" do
        let(:params) { {} }

        it "should assign the first 40 furl_requests" do
          expect(assigns[:furl_requests]).to be == furl_requests[0..39]
        end
      end

      context "page param is 2" do
        let(:params) { { page: 2 } }

        it "should assign the latter 5 furl_requests" do
          expect(assigns[:furl_requests]).to be == furl_requests[40..44]
        end
      end
    end
  end

  describe "#show" do
    context "with a furl_request" do
      let!(:furl_request) { create :furl_request }

      context "when requesting a furl_request which exists" do
        before { get :show, id: furl_request.id }

        specify { expect(assigns(:furl_request)).to eql furl_request }
      end

      context "when requesting a furl_request which doesn't exist" do
        before { get :show, id: "1234567890" }

        specify { expect(response.status).to eql 404 }
      end
    end
  end

  describe "#new" do
    before {
      get :new
    }

    context "with a user with an organisation" do
      let!(:organisation) { create(:organisation) }
      let(:user) { create(:user, permissions: ['signon', 'request_furls', 'manage_furls'], organisation_slug: organisation.slug) }

      it "should assign a new FurlRequest with the organisation_slug set to the current user's organisaiton" do
        expect(assigns[:furl_request]).to_not be_nil
        expect(assigns[:furl_request].organisation_slug).to eql organisation.slug
      end
    end
  end

  describe "#create" do
    let!(:organisation) { create :organisation }
    before {
      unless self.class.metadata[:without_first_posting]
        post :create, params
      end
    }

    context "with valid params" do
      let(:params) { {
        furl_request: {
          from: "/a-friendly-url",
          to: "/somewhere/a-document",
          reason: "Because wombles",
          contact_email: "wombles@example.com",
          organisation_slug: organisation.slug
        }
      } }

      it "should create a furl_request" do
        furl_request = FurlRequest.last
        expect(furl_request).to_not be_nil
        expect(furl_request.from).to               eql params[:furl_request][:from]
        expect(furl_request.to).to                 eql params[:furl_request][:to]
        expect(furl_request.reason).to             eql params[:furl_request][:reason]
        expect(furl_request.contact_email).to      eql params[:furl_request][:contact_email]
        expect(furl_request.organisation_slug).to  eql organisation.slug
        expect(furl_request.organisation_title).to eql organisation.title
      end

      it "should associate the current user with the furl_request" do
        expect(FurlRequest.last.requester).to eql user
      end

      it "should redirect to the dashboard with a flash message" do
        expect(response).to redirect_to root_path
        expect(flash).not_to be_empty
      end

      it "should send a furl_requested notificaiton", without_first_posting: true do
        mock_mail = double
        expect(mock_mail).to receive(:deliver)
        expect(Notifier).to receive(:furl_requested).with(kind_of(FurlRequest)).and_return(mock_mail)
        post :create, params
      end
    end

    context "with invalid params" do
      let (:params) { {
        furl_request: {
          from: '',
          to: ''
        }
      } }

      specify { expect(response).to render_template('furl_requests/new') }
      specify { expect(FurlRequest.count).to eql 0 }
    end
  end

  describe "#accept" do
    include GdsApi::TestHelpers::PublishingApi

    before {
      stub_default_publishing_api_put
    }

    context "when given an id of an existing furl request" do
      let!(:furl_request) { create :furl_request }
      before {
        unless self.class.metadata[:without_first_posting]
          post :accept, id: furl_request.id
        end
      }

      it "should create a Furl based on the furl request given" do
        created_furl = Furl.last
        expect(created_furl).to_not be_nil
        expect(created_furl.request).to eql furl_request
        expect(created_furl.from).to eql furl_request.from
        expect(created_furl.to).to eql furl_request.to
      end

      it "should assign the Furl" do
        expect(assigns(:furl)).to be_a Furl
      end

      it "should send a furl_request_accepted notificaiton", without_first_posting: true do
        mock_mail = double
        expect(mock_mail).to receive(:deliver)
        expect(Notifier).to receive(:furl_request_accepted).with(kind_of(FurlRequest)).and_return(mock_mail)
        post :accept, id: furl_request.id
      end
    end
  end

  describe "new_rejection" do
    let!(:furl_request) { create :furl_request }
    before {
      get :new_rejection, id: furl_request.id
    }

    it "should assign the furl_request" do
      expect(assigns(:furl_request)).to eql furl_request
    end
  end

  describe "reject" do
    let!(:furl_request) { create :furl_request }
    let(:rejection_reason) { "Don't like it!" }
    before {
      unless self.class.metadata[:without_first_posting]
        get :reject, id: furl_request.id, furl_request: {rejection_reason: rejection_reason}
      end
    }

    it "should update the rejection_reason on the furl_request" do
      expect(furl_request.reload.rejection_reason).to eql rejection_reason
    end

    it "should redirect to the furl_request index with a flash message" do
      expect(response).to redirect_to(furl_requests_path)
      expect(flash).not_to be_empty
    end

    it "should send a furl_request_rejected notificaiton", without_first_posting: true do
      mock_mail = double
      expect(mock_mail).to receive(:deliver)
      expect(Notifier).to receive(:furl_request_rejected).with(kind_of(FurlRequest)).and_return(mock_mail)
      post :reject, id: furl_request.id
    end
  end

  describe "organisations" do
    context "with some organisations" do
      let!(:organisation_m) { create :organisation, slug: "m-organisation", title: "M organisation" }
      let!(:organisation_z) { create :organisation, slug: "z-organisation", title: "Z organisation" }
      let!(:organisation_a) { create :organisation, slug: "a-organisation", title: "A organisation" }

      it "should return all organisations in alphabetical order" do
        expect(controller.organisations).to be == [organisation_a, organisation_m, organisation_z]
      end
    end
  end
end
