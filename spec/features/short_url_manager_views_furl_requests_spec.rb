require 'rails_helper'

feature "Short URL manager finds information on short_url requests" do
  background do
    login_as create(:user, permissions: ['signon', 'manage_short_urls'])
  end

  scenario "Short URL manager views the index of short_url requests and uses the pagination" do
    create :short_url_request, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-beards",
                          organisation_title: "Ministry of Beards",
                          created_at: 10.minutes.ago

    40.times do |n|
      create :short_url_request, from_path: "/from/path/#{n+2}",
                            created_at: n.days.ago
    end

    visit "/"
    click_on "Manage short URL requests"

    expect(page).to have_content "/ministry-of-beards"
    expect(page).to have_content "/government/organisations/ministry-of-beards"
    expect(page).to have_content "Ministry of Beards"

    expect(page).to have_content "/from/path/2"
    expect(page).to have_content "/from/path/40"
    expect(page).to have_no_content "/from/path/41"

    click_on "Next", match: :first

    expect(page).to have_content "/from/path/41"
    expect(page).to have_no_content "/from/path/40"
  end

  scenario "Short URL manager views the details for a single fRUL request" do
    create :short_url_request, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-beards",
                          reason: "Because we really need to think about beards",
                          contact_email: "gandalf@example.com",
                          created_at: Time.zone.parse("2014-01-01 12:00:00"),
                          organisation_title: "Ministry of Beards"

    visit short_url_requests_path

    click_on "Ministry of Beards"

    expect(page).to have_content "Ministry of Beards"
    expect(page).to have_content "12:00pm, 1 January 2014"
    expect(page).to have_content "/ministry-of-beards"
    expect(page).to have_link "/government/organisations/ministry-of-beards", href: "http://www.dev.gov.uk/government/organisations/ministry-of-beards"
    expect(page).to have_content "Because we really need to think about beards"
    expect(page).to have_content "gandalf@example.com"
  end

  scenario "User without manage_short_urls permission sees no option to manage short_url requests" do
    login_as create(:user, permissions: ['signon'])
    visit "/"
    expect(page).to have_no_content('Manage short URL requests')
  end
end
