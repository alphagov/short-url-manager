source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
gem 'sass-rails', '~> 5.0.3'

gem 'mongoid', '~> 4.0.0'
gem 'mongoid_rails_migrations', '~> 1.0.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.5.1'

gem 'unicorn', '~> 4.8.3'
gem 'airbrake', '~> 4.0.0'
gem 'logstasher', '~> 0.5.3'
gem 'whenever', '~> 0.9.2', :require => false
gem 'will_paginate_mongoid', '~> 2.0.1'
gem 'redis', '3.0.7', require: false # Used by the Organisation importer as a locking mechanism
gem 'mlanett-redis-lock', '0.2.2' # Used by the Organisation importer as a locking mechanism
gem 'gretel', '3.0.8'

gem 'govuk_admin_template', '~> 4.1'
gem 'gds-sso', '~> 11.2'
gem 'plek', '~> 1.8.1'
gem 'gds-api-adapters', '20.1.1'

group :development, :test do
  gem 'rspec-rails', '~> 3.2.1'
  gem 'factory_girl_rails', '~> 4.4.1'

  gem 'simplecov', '~> 0.8.2', :require => false
  gem 'simplecov-rcov', '~> 0.2.3', :require => false
  gem 'capybara', '~> 2.4.1'
  # NOTE: 1.5.0 has a bug with mongoid http://git.io/v02vQ
  gem 'database_cleaner', '~> 1.4.0'
  gem 'webmock', '~> 1.18.0', :require => false

  gem 'byebug'
  gem 'govuk-content-schema-test-helpers'
end
