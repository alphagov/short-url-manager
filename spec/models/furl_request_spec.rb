require 'rails_helper'

describe FurlRequest do
  let(:instance) { FurlRequest.new(attributes) }
  let(:attributes) { {
    from: from,
    to: to,
    reason: reason,
    contact_email: contact_email
  } }
  let(:from) { "/some-friendly-url" }
  let(:to) { "/government/some-publication" }
  let(:reason) { "Some reason" }
  let(:contact_email) { "someone@example.com" }

  describe "validations:" do
    specify { expect(instance).to be_valid }

    context "without 'from'" do
      let(:from) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "without 'to'" do
      let(:to) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "without 'reason'" do
      let(:reason) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "without 'contact_email'" do
      let(:contact_email) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'contact_email' is present, but not a valid email address" do
      let(:contact_email) { 'invalid.email.address' }
      specify { expect(instance).to_not be_valid }
    end
  end
end
