# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.find_or_create_by!(email: "user@test.example").tap do |u|
  u.name = "Test User"
  u.permissions = %w[signin manage_short_urls request_short_urls advanced_options receive_notifications]
  u.save!
end
