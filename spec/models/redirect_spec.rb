require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'
require "securerandom"

describe Redirect do
  include GdsApi::TestHelpers::PublishingApiV2
  include PublishingApiHelper

  include_examples "ShortUrlValidations", :redirect

  describe "content_id attribute" do
    it "generates its own content ID on creation" do
      expect(subject.content_id).to be_present
    end

    it "does not overwrite a provided content ID" do
      content_id = SecureRandom.uuid
      redirect = described_class.new(content_id: content_id)

      expect(redirect.content_id).to eq(content_id)
    end
  end

  describe "validations" do
    let(:non_factory_attrs) { {} }
    let(:instance) { build(:redirect, non_factory_attrs) }

    specify { expect(instance).to be_valid }

    context "with a duplicate `from_path`" do
      before do
        stub_any_publishing_api_call
        @existing_redirect = FactoryGirl.create(:redirect)
      end

      let(:non_factory_attrs) {
        {
          from_path: @existing_redirect.from_path
        }
      }

      specify { expect(instance).to_not be_valid }
    end
  end

  describe "posting to publishing API" do
    let(:redirect) { build :redirect }
    let(:expected_request) {}

    context "when saving and the publishing api is available" do
      before {
        stub_any_publishing_api_call
        redirect.save
      }

      context "with a valid redirect" do
        let(:redirect) { build :redirect }

        it "should post a redirect content item to the publishing API" do
          redirect_hash = publishing_api_redirect_hash(redirect.from_path, redirect.to_path, redirect.route_type, redirect.segments_mode)
          assert_publishing_api_put_content(redirect.content_id, redirect_hash)
          assert_publishing_api_publish(redirect.content_id)
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
