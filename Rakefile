# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'ci/reporter/rake/rspec'

Rails.application.load_tasks

task :default => :spec

if defined?(RSpec)
  RSpec::Core::RakeTask.new(:validate) do |t|
    t.pattern = "spec/presenters/publishing_api_presenter_spec.rb"
  end
end
