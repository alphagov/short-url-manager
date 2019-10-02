require "gds_api/organisations"
require "redis"
require "redis-lock"

class OrganisationImporter
  attr_reader :api_url_base

  def initialize(api_url_base = nil)
    @api_url_base = api_url_base || Plek.current.website_root
  end

  def perform!
    redis.lock("short_url_manager:#{Rails.env}:organisation_importer_lock", life: 2.hours) do
      organisations_data = get_organisations_data
      Organisation.destroy_all
      organisations_data.each { |attrs|
        Organisation.create(attrs)
      }
    end
  rescue Redis::Lock::LockNotAcquired => e
    Rails.logger.warn("Failed to get lock for importing organisations (#{e.message}). Another process probably got there first.")
  end

private

  def get_organisations_data
    api_adapter.organisations.with_subsequent_pages.map do |result|
      {
        title: result.dig("title"),
        slug: result.dig("details", "slug"),
      }
    end
  end

  def api_adapter
    @api_adapter ||= GdsApi::Organisations.new(api_url_base)
  end

  def redis
    redis_config = Rails.application.config_for(:redis)
    Redis.new(redis_config.symbolize_keys)
  end
end
