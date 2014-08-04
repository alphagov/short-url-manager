require 'rails_helper'

describe User do
  let(:instance) { User.new(attributes) }
  let(:attributes) { {
    permissions: permissions
  } }
  let(:permissions) { ['signin'] }

  describe "permissions" do
    context "user has no special permissions" do
      specify { expect(instance.can_request_furls?).to be_falsy }
      specify { expect(instance.can_manage_furls?).to be_falsy }
    end

    context "user has request_furls permission" do
      let(:permissions) { ['signin', 'request_furls'] }
      specify { expect(instance.can_request_furls?).to be_truthy }
      specify { expect(instance.can_manage_furls?).to be_falsy }
    end

    context "user has manage_furls permission" do
      let(:permissions) { ['signin', 'manage_furls'] }
      specify { expect(instance.can_request_furls?).to be_falsy }
      specify { expect(instance.can_manage_furls?).to be_truthy }
    end
  end

  describe "scopes" do
    context "with several users of various types" do
      let!(:furl_managers) {
        2.times.map { create :furl_manager }
      }
      let!(:other_users) {
        2.times.map { create :furl_requester }
      }

      describe "#furl_managers" do
        subject { User.furl_managers }

        it "should return only users with the manage_furls permission" do
          expect(subject.length).to eql 2
          expect(subject).to include *furl_managers
          expect(subject).to_not include *other_users
        end
      end
    end
  end
end
