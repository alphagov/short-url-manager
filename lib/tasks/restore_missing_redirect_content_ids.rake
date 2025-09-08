namespace :redirects do
  desc "Restore missing content IDs for redirects from Publishing API. Hopefully we should only ever run this task once."
  task restore_missing: :environment do
    RedirectContentIdRestorer.perform!
  end
end
