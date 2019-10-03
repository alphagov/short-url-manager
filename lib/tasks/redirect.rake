namespace :redirect do
  desc "Destroy and unpublish a redirect."
  task :destroy, %i[content_id] => :environment do |_, args|
    content_id = args.fetch(:content_id)
    Redirect.find_by!(content_id: content_id).destroy
  end
end
