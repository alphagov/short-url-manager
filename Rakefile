# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

task default: %i[spec lint]

if defined?(RSpec)
  RSpec::Core::RakeTask.new(:validate) do |t|
    t.pattern = "spec/presenters/publishing_api_presenter_spec.rb"
  end
end
