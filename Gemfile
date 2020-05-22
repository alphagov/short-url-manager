source "https://rubygems.org"

gem "rails", "~> 5.2"
gem "sass-rails", "< 6"

gem "mongoid", "6.3.0"
gem "mongoid_rails_migrations", git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", "~> 4.2.0"

gem "gretel", "3.0.9"
gem "mlanett-redis-lock", "0.2.7" # Used by the Organisation importer as a locking mechanism
gem "redis", "4.1.4", require: false # Used by the Organisation importer as a locking mechanism
gem "whenever", "~> 1.0.0", require: false

gem "gds-api-adapters"
gem "gds-sso", "~> 14.3.0"
gem "govuk_admin_template", "~> 6.7"
gem "govuk_app_config", "~> 2.2.0"
gem "govuk_publishing_components", "~> 21.50.1"
gem "govuk_sidekiq", "~> 3.0"
gem "mail-notify"
gem "plek"

group :development, :test do
  gem "factory_bot_rails", "~> 5"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 4.0.1"

  gem "capybara", "~> 3.32.2"
  gem "database_cleaner", "~> 1.8.5"
  gem "simplecov", "~> 0.18.5", require: false
  gem "simplecov-rcov", "~> 0.2.3", require: false
  gem "webmock", "~> 3.8.3", require: false

  gem "byebug"
  gem "govuk-content-schema-test-helpers"
  gem "pry"
  gem "rubocop-govuk"
  gem "scss_lint-govuk"
end
