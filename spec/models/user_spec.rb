require 'rails_helper'

describe User do
  let(:instance) { User.new(attributes) }
  let(:attributes) { {
    permissions: permissions
  } }
  let(:permissions) { ['signin'] }

  describe "permissions" do
    context "user has no special permissions" do
      specify { expect(instance.can_request_short_urls?).to be_falsy }
      specify { expect(instance.can_manage_short_urls?).to be_falsy }
    end

    context "user has request_short_urls permission" do
      let(:permissions) { ['signin', 'request_short_urls'] }
      specify { expect(instance.can_request_short_urls?).to be_truthy }
      specify { expect(instance.can_manage_short_urls?).to be_falsy }
    end

    context "user has manage_short_urls permission" do
      let(:permissions) { ['signin', 'manage_short_urls'] }
      specify { expect(instance.can_request_short_urls?).to be_falsy }
      specify { expect(instance.can_manage_short_urls?).to be_truthy }
    end
  end

  describe "scopes" do
    context "with several users of various types" do
      let!(:short_url_managers) {
        2.times.map { create :short_url_manager }
      }
      let!(:other_users) {
        2.times.map { create :short_url_requester }
      }

      describe "#short_url_managers" do
        subject { User.short_url_managers }

        it "should return only users with the manage_short_urls permission" do
          expect(subject.length).to eql 2
          expect(subject).to include *short_url_managers
          expect(subject).to_not include *other_users
        end
      end
    end
  end
end
