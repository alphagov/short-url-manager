source "https://rubygems.org"

gem "rails", "~> 8.0.0"

gem "bootsnap", require: false
gem "dartsass-rails"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_admin_template"
gem "govuk_app_config"

gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "gretel"
gem "mail-notify"
gem "mlanett-redis-lock" # Used by the Organisation importer as a locking mechanism
gem "mongoid"
gem "plek"
gem "redis", require: false # Used by the Organisation importer as a locking mechanism
gem "sentry-sidekiq"
gem "terser"
gem "whenever", require: false
gem "will_paginate_mongoid"

group :development, :test do
  gem "brakeman"
  gem "byebug"
  gem "capybara"
  gem "database_cleaner-mongoid"
  gem "factory_bot_rails"
  gem "govuk_schemas"
  gem "listen"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "webmock", require: false
end
