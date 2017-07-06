require 'csv'

namespace :redirects do
  desc "Import redirects"
  task :import, [:file] => :environment do |_, args|
    data = CSV.read(args[:file])

    data.shift # Remove the CSV header

    created = 0
    skipped = 0
    errors = {}

    begin
      data.each do |row|
        fields = {
          from_path: row[0],
          to_path: row[1],
        }

        fields[:route_type] = row[2] if row[2].present?
        fields[:segments_mode] = row[3] if row[3].present?

        redirect = Redirect.where(from_path: fields[:from_path]).first

        if redirect.present?
          skipped += 1
          print '-'
        else
          begin
            Redirect.create!(fields)

            created += 1
            print '.'
          rescue StandardError => e
            errors[row] = e

            print 'x'
          end
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
    puts "  - skipped: #{skipped}"
    puts "  -  errors: #{errors.size}"
  end
end
