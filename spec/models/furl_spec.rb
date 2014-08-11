require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

describe Furl do
  include GdsApi::TestHelpers::PublishingApi
  include PublishingApiHelper

  describe "validations" do
    let(:non_factory_attrs) { {} }
    let(:instance) { build(:furl, non_factory_attrs) }

    specify { expect(instance).to be_valid }

    context "without from" do
      let(:non_factory_attrs) { { from: '' } }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'from' is present, but is not a relative path" do
      let(:non_factory_attrs) { { from: 'http://www.somewhere.com/a-path' } }
      specify { expect(instance).to_not be_valid }
    end

    context "without to" do
      let(:non_factory_attrs) { { to: '' } }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'to' is present, but is not a relative path" do
      let(:non_factory_attrs) { { to: 'http://www.somewhere.com/a-path' } }
      specify { expect(instance).to_not be_valid }
    end
  end

  describe "posting to publishing API" do
    let(:furl) { build :furl }
    let(:expected_request) {}

    context "when saving and the publishing api is available" do
      before {
        stub_default_publishing_api_put
        furl.save
      }

      context "with a valid furl" do
        let(:furl) { build :furl }

        it "should post a redirect content item to the publishing API" do
          assert_publishing_api_put_item(furl.from, publishing_api_redirect_hash(furl.from, furl.to))
        end
      end

      context "with an invalid furl" do
        let(:furl) { build :furl, :invalid }

        it "should not attempt to post anything to the publishing API" do
          expect(WebMock).to have_not_requested :any, /.*/
        end
      end
    end

    context "when trying to save when the publishing api isn't available" do
      before {
        publishing_api_isnt_available
        furl.save
      }

      it "should not save" do
        expect(Furl.count).to eql 0
      end

      it "should have an error on :base" do
        expect(furl.errors[:base]).to_not be_empty
      end
    end
  end
end
