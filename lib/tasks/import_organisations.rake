namespace :organisations do
  desc "Import organisations | Optionally set API_URL_BASE env variable (to 'https://www.gov.uk' for example) - default depends on current environment."
  task import: :environment do
    OrganisationImporter.new(ENV["API_URL_BASE"]).perform!
  end
end
