require 'rails_helper'

describe FurlRequest do
  describe "validations:" do
    specify { expect(build :furl_request).to be_valid }
    specify { expect(build :furl_request, from: '').to_not be_valid }
    specify { expect(build :furl_request, to: '').to_not be_valid }
    specify { expect(build :furl_request, reason: '').to_not be_valid }
    specify { expect(build :furl_request, contact_email: '').to_not be_valid }
    specify { expect(build :furl_request, contact_email: 'invalid.email.address').to_not be_valid }
    specify { expect(build :furl_request, organisation_title: '').to_not be_valid }
    specify { expect(build :furl_request, organisation_slug: '').to_not be_valid }

    it "should be invalid when from is not a relative path" do
      expect(build :furl_request, from: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when to is not a relative path" do
      expect(build :furl_request, to: 'http://www.somewhere.com/a-path').to_not be_valid
    end
    it "should be invalid when contact_email is not a valid email address" do
      expect(build :furl_request, contact_email: 'invalid.email.address').to_not be_valid
    end
  end

  describe "organisation fields" do
    context "when an organisation slug for an existing organisation is given" do
      let!(:organisation) { create :organisation }
      let(:instance) { build :furl_request, organisation_slug: organisation.slug,
                                            organisation_title: organisation.title
      }

      it "should set organisation_title to that of the organisation before validating" do
        expect(instance).to be_valid
        expect(instance.organisation_title).to eql organisation.title
      end
    end
  end
end
