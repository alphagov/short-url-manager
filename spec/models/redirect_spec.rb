require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe Redirect do
  include GdsApi::TestHelpers::PublishingApi
  include PublishingApiHelper

  describe "validations" do
    let(:non_factory_attrs) { {} }
    let(:instance) { build(:redirect, non_factory_attrs) }

    specify { expect(instance).to be_valid }

    context "without from_path" do
      let(:non_factory_attrs) { { from_path: '' } }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'from_path' is present, but is not a relative path" do
      let(:non_factory_attrs) { { from_path: 'http://www.somewhere.com/a-path' } }
      specify { expect(instance).to_not be_valid }
    end

    context "without to_path" do
      let(:non_factory_attrs) { { to_path: '' } }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'to_path' is present, but is not a relative path" do
      let(:non_factory_attrs) { { to_path: 'http://www.somewhere.com/a-path' } }
      specify { expect(instance).to_not be_valid }
    end
  end

  describe "posting to publishing API" do
    let(:redirect) { build :redirect }
    let(:expected_request) {}

    context "when saving and the publishing api is available" do
      before {
        stub_default_publishing_api_put
        redirect.save
      }

      context "with a valid redirect" do
        let(:redirect) { build :redirect }

        it "should post a redirect content item to the publishing API" do
          assert_publishing_api_put_item(redirect.from_path, publishing_api_redirect_hash(redirect.from_path, redirect.to_path))
        end
      end

      context "with an invalid redirect" do
        let(:redirect) { build :redirect, :invalid }

        it "should not attempt to post anything to the publishing API" do
          expect(WebMock).to have_not_requested :any, /.*/
        end
      end
    end

    context "when trying to save when the publishing api isn't available" do
      before {
        publishing_api_isnt_available
        redirect.save
      }

      it "should not save" do
        expect(Redirect.count).to eql 0
      end

      it "should have an error on :base" do
        expect(redirect.errors[:base]).to_not be_empty
      end
    end
  end
end
