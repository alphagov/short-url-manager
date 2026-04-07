require "thor"

namespace :redirects do
  desc "Create and apply a redirect without requiring approval."
  task :create_and_apply, %i[contact_email from_path to_path reason override_existing route_type segments_mode organisation_slug organisation_title] => :environment do |_, args|
    request = ShortUrlRequest.new(
      contact_email: args[:contact_email],
      from_path: args[:from_path],
      to_path: args[:to_path],
      reason: args[:reason],
      override_existing: args[:override_existing] == "true",
      route_type: args[:route_type] || "exact", # or "prefix"
      segments_mode: args[:segments_mode] || "ignore", # or "preserve"
      organisation_slug: args[:organisation_slug] || "government-digital-service",
      organisation_title: args[:organisation_title] || "Government Digital Service",
    )

    if Thor::Shell::Basic.new.yes?("This will create and apply a #{request.route_type} redirect from #{request.from_path} to #{request.to_path}. Are you sure you want to continue?")
      request.save!
      Commands::ShortUrlRequests::Accept.new(request).call(failure: -> { raise "Something went wrong" })
    else
      puts "Aborting"
    end
  end
end
