require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe ShortUrlRequestsController do
  let(:user) { create(:short_url_requester_and_manager) }
  before { login_as user }

  describe "access control" do
    context "with a user without any permissions" do
      let(:user) { create(:user) }

      specify do
        expect_not_authorised(:get, :remove, id: "required-param")
        expect_not_authorised(:post, :destroy, id: "required-param")
      end
    end

    context "with a user without request_short_urls permission" do
      let(:user) { create(:short_url_manager) }

      specify do
        expect_not_authorised(:get, :new)
        expect_not_authorised(:post, :create)
      end
    end

    context "with a user without manage_short_urls permission" do
      let(:user) { create(:short_url_requester) }

      specify do
        expect_not_authorised(:get, :index)
        expect_not_authorised(:get, :show, id: "required-param")
        expect_not_authorised(:post, :accept, id: "required-param")
        expect_not_authorised(:get, :new_rejection, id: "required-param")
        expect_not_authorised(:post, :reject, id: "required-param")
        expect_not_authorised(:get, :remove, id: "required-param")
        expect_not_authorised(:post, :destroy, id: "required-param")
      end
    end
  end

  describe "#index" do
    context "with several short_url_requests requested at different times" do
      let!(:short_url_requests) do
        [
          create(:short_url_request, :pending, created_at: 10.days.ago),
          create(:short_url_request, :pending, created_at: 5.days.ago),
          create(:short_url_request, :pending, created_at: 15.days.ago),
        ]
      end
      before { get :index }

      it "should order short_url_requests by created_at date with the most recent first" do
        expect(assigns[:short_url_requests]).to be == [short_url_requests[1], short_url_requests[0], short_url_requests[2]]
      end
    end

    context "with 45 short_url_requests" do
      let!(:short_url_requests) { 45.times.map { |n| create :short_url_request, :pending, created_at: n.days.ago } }
      before { get :index, params: params }

      context "page param is not given" do
        let(:params) { {} }

        it "should assign the first 40 short_url_requests" do
          expect(assigns[:short_url_requests]).to be == short_url_requests[0..39]
        end
      end

      context "page param is 2" do
        let(:params) { { page: 2 } }

        it "should assign the latter 5 short_url_requests" do
          expect(assigns[:short_url_requests]).to be == short_url_requests[40..44]
        end
      end
    end

    context "with several different states of short_url_request" do
      let!(:pending_short_url_request) { create(:short_url_request, :pending) }
      let!(:accepted_short_url_request) { create(:short_url_request, :accepted) }
      let!(:rejected_short_url_request) { create(:short_url_request, :rejected) }
      before { get :index }

      it "should only include pending requests" do
        expect(assigns(:short_url_requests)).to be == [pending_short_url_request]
      end
    end
  end

  describe "#show" do
    context "with a short_url_request" do
      let!(:short_url_request) { create :short_url_request }

      context "when requesting a short_url_request which exists" do
        before { get :show, params: { id: short_url_request.id } }

        specify { expect(assigns(:short_url_request)).to eql short_url_request }
      end

      context "when requesting a short_url_request which doesn't exist" do
        before { get :show, params: { id: "1234567890" } }

        specify { expect(response.status).to eql 404 }
      end
    end
  end

  describe "#new" do
    before do
      get :new
    end

    context "with a user with an organisation" do
      let!(:organisation) { create(:organisation) }
      let(:user) { create(:short_url_requester_and_manager, organisation_slug: organisation.slug) }

      it "should assign a new ShortUrlRequest with the organisation_slug set to the current user's organisaiton" do
        expect(assigns[:short_url_request]).to_not be_nil
        expect(assigns[:short_url_request].organisation_slug).to eql organisation.slug
      end
    end
  end

  describe "#create" do
    let!(:organisation) { create :organisation }

    context "with valid params" do
      let(:params) do
        {
          short_url_request: {
            from_path: "/a-friendly-url",
            to_path: "/somewhere/a-document",
            reason: "Because wombles",
            organisation_slug: organisation.slug,
          },
        }
      end

      it "should create a short_url_request" do
        post :create, params: params
        short_url_request = ShortUrlRequest.last
        expect(short_url_request).to_not be_nil
        expect(short_url_request.from_path).to          eql params[:short_url_request][:from_path]
        expect(short_url_request.to_path).to            eql params[:short_url_request][:to_path]
        expect(short_url_request.reason).to             eql params[:short_url_request][:reason]
        expect(short_url_request.contact_email).to      eql user.email
        expect(short_url_request.organisation_slug).to  eql organisation.slug
        expect(short_url_request.organisation_title).to eql organisation.title
      end

      it "should associate the current user with the short_url_request" do
        post :create, params: params
        expect(ShortUrlRequest.last.requester).to eql user
      end

      it "should redirect to the dashboard with a flash message" do
        post :create, params: params
        expect(response).to redirect_to root_path
        expect(flash).not_to be_empty
      end

      it "should send a short_url_requested notification" do
        mock_mail = double
        expect(mock_mail).to receive(:deliver_later)
        expect(RequestNotifier).to receive(:email).with(:short_url_requested, kind_of(ShortUrlRequest)).and_return([mock_mail])
        post :create, params: params
      end

      context "when an existing redirect already exists" do
        include GdsApi::TestHelpers::PublishingApi

        before do
          stub_any_publishing_api_call
          create(:redirect, from_path: params[:short_url_request][:from_path])
        end

        it "does not create a short_url_request" do
          post :create, params: params
          expect(ShortUrlRequest.count).to eq(0)
        end

        context "and the request is confirmed" do
          let(:params) do
            {
              short_url_request: {
                from_path: "/a-friendly-url",
                to_path: "/somewhere/a-document",
                reason: "Because wombles",
                organisation_slug: organisation.slug,
                confirmed: true,
              },
            }
          end

          it "creates a short url request" do
            post :create, params: params
            expect(ShortUrlRequest.count).to eq(1)
          end
        end
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          short_url_request: {
            from_path: "",
            to_path: "",
          },
        }
      end

      before { post :create, params: params }

      specify { expect(response).to render_template("short_url_requests/new") }
      specify { expect(ShortUrlRequest.count).to eql 0 }
    end
  end

  describe "#accept" do
    include GdsApi::TestHelpers::PublishingApi

    let!(:short_url_request) { create :short_url_request }

    context "redirects can be created without problem" do
      before do
        stub_any_publishing_api_call
        post :accept, params: { id: short_url_request.id }
      end

      it "should assign the ShortUrlRequest" do
        expect(assigns(:short_url_request)).to eql short_url_request
      end

      it "should have accepted the short_url_request" do
        expect(short_url_request.reload).to be_accepted
      end
    end

    context "publishing api isn't available" do
      before do
        stub_publishing_api_isnt_available
        post :accept, params: { id: short_url_request.id }
      end

      it "should render the accept_failed template" do
        expect(response).to render_template("short_url_requests/accept_failed")
      end
    end

    context "a redirect already exists with that from_path in the request" do
      before do
        stub_any_publishing_api_call

        existing_url_request = FactoryBot.create(
          :short_url_request,
          from_path: short_url_request.from_path,
        )
        @existing_redirect = FactoryBot.create(
          :redirect,
          to_path: "/some/existing/path",
          from_path: short_url_request.from_path,
          short_url_request: existing_url_request,
        )
      end

      it "should update the existing redirect" do
        post :accept, params: { id: short_url_request.id }

        expect(response.status).to eq(200)
        expect(@existing_redirect.reload.to_path).to eq(short_url_request.to_path)
      end
    end
  end

  describe "new_rejection" do
    let!(:short_url_request) { create :short_url_request }
    before do
      get :new_rejection, params: { id: short_url_request.id }
    end

    it "should assign the short_url_request" do
      expect(assigns(:short_url_request)).to eql short_url_request
    end
  end

  describe "reject" do
    let!(:short_url_request) { create :short_url_request }
    let(:rejection_reason) { "Don't like it!" }
    before do
      post :reject, params: { id: short_url_request.id, short_url_request: { rejection_reason: rejection_reason } }
    end

    it "should reject the short_url request, passing in the given reason" do
      expect(short_url_request.reload.rejection_reason).to eql rejection_reason
    end

    it "should redirect to the short_url_request index with a flash message" do
      expect(response).to redirect_to(short_url_requests_path)
      expect(flash).not_to be_empty
    end
  end

  describe "#edit" do
    let!(:short_url_request) { create :short_url_request }

    it "displays the form" do
      get :edit, params: { id: short_url_request.id }
      expect(response.status).to eql(200)
    end
  end

  describe "#update" do
    let!(:organisation) { create(:organisation) }
    let!(:short_url_request) { create(:short_url_request, from_path: "/original") }

    context "with valid parameters" do
      let(:params) do
        {
          from_path: short_url_request.from_path,
          to_path: "/somewhere/different",
          reason: "Because wombles",
          organisation_slug: organisation.slug,
        }
      end

      it "saves the changes" do
        put :update, params: { id: short_url_request.id, short_url_request: params }
        expect(response).to redirect_to(short_url_request_path(short_url_request))

        short_url_request.reload
        expect(short_url_request.to_path).to eql("/somewhere/different")
      end
    end

    context "with a change to the from_path" do
      let(:params) do
        {
          from_path: "/a-changed-from-path",
          to_path: "/somewhere/a-document",
          reason: "Because wombles",
          organisation_slug: organisation.slug,
        }
      end

      it "rejects changes to the from_path" do
        put :update, params: { id: short_url_request.id, short_url_request: params }

        short_url_request.reload
        expect(short_url_request.from_path).to eql("/original")
      end
    end
  end

  describe "#remove" do
    let!(:organisation) { create(:organisation) }
    let!(:short_url_request) { create(:short_url_request, :accepted, from_path: "/original") }
    render_views
    context "with a valid short url" do
      it "shows a confirm deletion message for the short-url" do
        get :remove, params: { id: short_url_request.id }
        expect(response).to have_http_status(200)
        expect(response).to render_template(:remove)
        expect(response.body).to include("Delete URL redirect or Short URL /original")
      end
    end
  end

  describe "#destroy" do
    let!(:organisation) { create(:organisation) }
    let!(:short_url_request) { create(:short_url_request, :accepted, from_path: "/original") }
    let!(:short_url_request_2) { create(:short_url_request, :accepted, from_path: "/other-original") }
    context "with a valid short url" do
      it "destroys and unpublishes the short-url" do
        unpublish_req = stub_any_publishing_api_call
          .with(body: '{"type":"gone"}')
        stub_any_publishing_api_call
        put :destroy, params: { id: short_url_request.id }
        expect(response).to redirect_to(short_url_requests_path)
        expect(ShortUrlRequest.all).to eq([short_url_request_2])
        expect(Redirect.all).to eq([short_url_request_2.redirect])
        assert_requested(unpublish_req)
      end
    end

    context "with an invalid short url" do
      it "returns a 404" do
        unpublish_req = stub_any_publishing_api_call
          .with(body: '{"type":"gone"}')
        stub_any_publishing_api_call
        put :destroy, params: { id: 123 }
        expect(response).to have_http_status(:not_found)
        expect(ShortUrlRequest.count).to eq(2)
        expect(Redirect.count).to eq(2)
        assert_not_requested(unpublish_req)
      end
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
