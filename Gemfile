source 'https://rubygems.org'

gem 'rails', '~> 5.1'
gem 'sass-rails', '~> 5.0'

gem 'mongoid', '6.0.2'
gem 'mongoid_rails_migrations', git: "https://github.com/alphagov/mongoid_rails_migrations", branch: "avoid-calling-bundler-require-in-library-code-v1.1.0-plus-mongoid-v5-fix"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 3.0.2'

gem 'unicorn', '~> 5.1.0'
gem 'logstasher', '~> 0.5.3'
gem 'whenever', '~> 0.9.2', require: false
gem 'will_paginate_mongoid', '~> 2.0.1'
gem 'redis', '3.3.1', require: false # Used by the Organisation importer as a locking mechanism
gem 'mlanett-redis-lock', '0.2.7' # Used by the Organisation importer as a locking mechanism
gem 'gretel', '3.0.9'

gem 'govuk_admin_template', '~> 4.1'
gem 'gds-sso', '~> 13.4.0'
gem 'plek'
gem 'gds-api-adapters'
gem "govuk_app_config", "~> 0.2.0"

group :development, :test do
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.5.2'
  gem 'factory_girl_rails', '~> 4.7.0'

  gem 'simplecov', '~> 0.12.0', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
  gem 'capybara', '~> 2.8.1'
  gem 'database_cleaner', '~> 1.5.3'
  gem 'webmock', '~> 2.3.0', require: false

  gem 'byebug'
  gem 'pry'
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
end
