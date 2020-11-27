source "https://rubygems.org"

gem "rails", "6.0.3.4"

gem "sass-rails"

gem "mongoid"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier"

gem "gretel"
gem "mlanett-redis-lock" # Used by the Organisation importer as a locking mechanism
gem "redis", require: false # Used by the Organisation importer as a locking mechanism
gem "whenever", require: false
gem "will_paginate_mongoid"

gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "mail-notify"
gem "plek"

group :development, :test do
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "rspec-rails"

  gem "capybara"
  gem "database_cleaner"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "webmock", require: false

  gem "byebug"
  gem "govuk-content-schema-test-helpers"
  gem "pry"
  gem "rubocop-govuk"
  gem "scss_lint-govuk"
end
