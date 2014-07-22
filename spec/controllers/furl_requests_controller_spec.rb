require 'rails_helper'

describe FurlRequestsController do
  describe "#create" do
    before {
      post :create, params
    }

    context "with valid params" do
      let(:params) { {
        furl_request: {
          from: "/a-friendly-url",
          to: "/somewhere/a-document",
          reason: "Because wombles",
          contact_email: "wombles@example.com"
        }
      } }

      it "should create a furl_request" do
        furl_request = FurlRequest.last
        expect(furl_request).to_not be_nil
        expect(furl_request.from).to          eql params[:furl_request][:from]
        expect(furl_request.to).to            eql params[:furl_request][:to]
        expect(furl_request.reason).to        eql params[:furl_request][:reason]
        expect(furl_request.contact_email).to eql params[:furl_request][:contact_email]
      end

      it "should redirect to the dashboard with a flash message" do
        expect(response).to redirect_to root_path
        expect(flash).not_to be_empty
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
end
