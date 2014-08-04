require 'gds_api/organisations'

class OrganisationImporter
  attr_reader :api_url_base

  def initialize(api_url_base = nil)
    @api_url_base = api_url_base || Plek.current.find("whitehall-admin")
  end

  def perform!
    organisations_data = get_organisations_data
    Organisation.destroy_all
    organisations_data.each {|attrs|
      Organisation.create(attrs)
    }
  end

private
  def get_organisations_data
    api_adapter.organisations.with_subsequent_pages.map {|result|
      {
        title: result.title,
        slug: result.details.slug
      }
    }
  end

  def api_adapter
    @api_adapter ||= GdsApi::Organisations.new(api_url_base)
  end
end
