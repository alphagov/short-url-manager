require "rails_helper"
require "gds_api/test_helpers/organisations"

describe OrganisationImporter do
  include GdsApi::TestHelpers::Organisations

  context "The API responds with 2 pages of results" do
    before {
      org_slugs = %w[wombats-of-wimbledon]
      org_slugs.concat(49.times.map { |n| "organisation-#{n}" })
      organisations_api_has_organisations(org_slugs)
    }

    context "without any existing organisations" do
      before {
        OrganisationImporter.new.perform!
      }

      it "should have made 50 organisations" do
        expect(Organisation.count).to eql 50
      end

      it "should have built the organisations with the correct attributes" do
        wombats_org = Organisation.where(slug: "wombats-of-wimbledon").first
        expect(wombats_org).to_not be_nil
        expect(wombats_org.title).to eql "Wombats Of Wimbledon"
      end
    end

    context "with an existing organisation" do
      before {
        Organisation.create(slug: "ministry-of-beards", title: "Ministry of Beards")

        OrganisationImporter.new.perform!
      }

      it "should destroy existing organisations" do
        expect(Organisation.where(slug: "ministry-of-beards").first).to be_nil
      end
    end
  end
end
