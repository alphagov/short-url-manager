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
end
