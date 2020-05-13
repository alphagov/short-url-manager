require "rails_helper"
require "gds-sso/lint/user_spec"

describe User do
  it_behaves_like "a gds-sso user class"

  let(:instance) { User.new(attributes) }
  let(:attributes) do
    {
      permissions: permissions,
    }
  end
  let(:permissions) { %w[signin] }

  describe "permissions" do
    context "user has no special permissions" do
      specify { expect(instance.can_request_short_urls?).to be_falsy }
      specify { expect(instance.can_manage_short_urls?).to be_falsy }
    end

    context "user has request_short_urls permission" do
      let(:permissions) { %w[signin request_short_urls] }
      specify { expect(instance.can_request_short_urls?).to be_truthy }
      specify { expect(instance.can_manage_short_urls?).to be_falsy }
    end

    context "user has manage_short_urls permission" do
      let(:permissions) { %w[signin manage_short_urls] }
      specify { expect(instance.can_request_short_urls?).to be_falsy }
      specify { expect(instance.can_manage_short_urls?).to be_truthy }
    end
  end

  describe "scopes" do
    context "with several users of various types" do
      let!(:short_url_managers) do
        2.times.map { create :short_url_manager }
      end
      let!(:other_users) do
        2.times.map { create :short_url_requester }
      end

      describe "#short_url_managers" do
        subject { User.short_url_managers }

        it "should return only users with the manage_short_urls permission" do
          expect(subject.length).to eql 2
          expect(subject).to include(*short_url_managers)
          expect(subject).to_not include(*other_users)
        end
      end
    end
  end
end
