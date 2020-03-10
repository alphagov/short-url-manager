class RemoveDuplicateRedirects < Mongoid::Migration
  def self.up
    Redirect.all.to_a.group_by(&:from_path).each do |_from_path, redirects|
      sorted_redirects = redirects.sort_by(&:updated_at)
      redirect_to_keep = sorted_redirects.pop
      puts "Keeping redirect #{redirect_to_keep.id}, #{redirect_to_keep.from_path}, #{redirect_to_keep.updated_at.iso8601}"

      sorted_redirects.each do |redirect|
        short_url_request = redirect.short_url_request

        puts "-- Discarding redirect #{redirect.id}, #{redirect.from_path}, #{redirect.updated_at.iso8601}"
        puts "---- Discarding short URL request #{short_url_request.id}, #{short_url_request.from_path}, #{short_url_request.updated_at.iso8601}"

        short_url_request.destroy
        redirect.destroy
      end
    end
  end
end
