require "csv"
require "gds_api/publishing_api"

namespace :redirects do
  desc "Import redirects"
  task :import, %i[file change_path_reservation? update_existing?] => :environment do |_, args|
    args.with_defaults(
      change_path_reservation?: false,
      update_existing?: false,
    )

    data = CSV.read(args[:file])

    data.shift # Remove the CSV header

    created = 0
    updated = 0
    skipped = 0
    errors = {}

    publishing_api_client = GdsApi.publishing_api

    begin
      data.each do |row|
        fields = {
          from_path: row[0],
          to_path: row[1],
        }

        fields[:route_type] = row[2] || "exact"

        default_segments_mode = case fields[:route_type]
                                when "exact"
                                  fields[:segments_mode] = "ignore"
                                when "prefix"
                                  fields[:segments_mode] = "preserve"
                                else
                                  raise "Unknown route type \"#{fields[:route_type]}\""
                                end

        fields[:segments_mode] = row[3] || default_segments_mode

        redirect = Redirect.where(from_path: fields[:from_path]).first

        if redirect.present? && !args[:update_existing?]
          skipped += 1
          print "-"
          next
        end

        begin
          if args[:change_path_reservation?]
            publishing_api_client.put_path(
              fields[:from_path],
              publishing_app: "short-url-manager",
              override_existing: true,
            )
          end

          if redirect.present?
            redirect.update!(fields)
            updated += 1
            print "*"
          else
            Redirect.create!(fields)
            created += 1
            print "."
          end
        rescue StandardError => e
          errors[row] = e

          print "x"
        end
      end
    rescue Interrupt
      puts "Stopping due to interrupt"
    end

    puts

    errors.each do |row, error|
      puts "Row: #{row}"
      puts error
    end

    puts
    puts "Import finished:"
    puts "  - created: #{created}"
    puts "  - updated: #{updated}"
    puts "  - skipped: #{skipped}"
    puts "  -  errors: #{errors.size}"
  end
end
