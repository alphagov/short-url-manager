require 'rails_helper'

describe FurlRequest do
  let(:instance) { FurlRequest.new(attributes) }
  let(:attributes) { {
    from: from,
    to: to,
    reason: reason,
    contact_email: contact_email,
    organisation_slug: organisation_slug,
    organisation_title: organisation_title
  } }
  let(:from) { "/some-friendly-url" }
  let(:to) { "/government/some-publication" }
  let(:reason) { "Some reason" }
  let(:contact_email) { "someone@example.com" }
  let(:organisation_slug) { 'organisation-slug' }
  let(:organisation_title) { 'Organisation Title' }

  describe "validations:" do
    specify { expect(instance).to be_valid }

    context "without 'from'" do
      let(:from) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'from' is present, but is not a relative path" do
      let(:from) { 'http://www.somewhere.com/a-path' }
      specify { expect(instance).to_not be_valid }
    end

    context "without 'to'" do
      let(:to) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "when 'to' is present, but is not a relative path" do
      let(:to) { 'http://www.somewhere.com/a-path' }
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

    context "without 'organisation_slug'" do
      let(:organisation_slug) { '' }
      specify { expect(instance).to_not be_valid }
    end

    context "without 'organisation_title'" do
      let(:organisation_title) { '' }
      specify { expect(instance).to_not be_valid }
    end
  end

  describe "organisation fields" do
    context "when an organisation slug for an existing organisation is given" do
      let!(:organisation) { create :organisation }
      let(:organisation_slug) { organisation.slug }
      let(:organisation_title) { nil }

      it "should set organisation_title to that of the organisation before validating" do
        expect(instance).to be_valid
        expect(instance.organisation_title).to eql organisation.title
      end
    end
  end
end
