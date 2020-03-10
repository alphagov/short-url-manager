require "csv"

class ImportRouterDataShortUrls < Mongoid::Migration
  def self.up
    CSV.foreach(__FILE__.sub(/.rb\z/, ".csv"), headers: true) do |row|
      from = row["from"]
      to = row["to"]
      org_slug = row["org_slug"]
      reason = row["reason"]

      puts "Importing #{from} -> #{to}"

      if ShortUrlRequest.where(state: "accepted", from_path: from).exists?
        puts "  Accepted request already exists, skipping..."
        next
      end

      req = ShortUrlRequest.new({
        state: "accepted",
        from_path: from,
        to_path: to,
        contact_email: "winston@alphagov.co.uk",
        reason: reason,
        organisation_slug: org_slug,
      })
      req.organisation_title = "Unknown" if org_slug == "unknown" # Avoid validation error looking up org
      req.save!

      retries = 0
      begin
        redirect = Redirect.new(from_path: req.from_path, to_path: req.to_path, short_url_request: req)
        unless redirect.save
          puts "  Failed to create redirect - #{redirect.errors.full_messages}"
        end
      rescue GdsApi::TimedOutException
        if retries < 3
          retries += 1
          puts "  Timeout, retry #{retries}..."
          sleep 0.1
          retry
        end
        raise
      end
    end
  end

  def self.down; end
end
