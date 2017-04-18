require 'rails_helper'

feature "Short URL manager finds information on short_url requests" do
  background do
    login_as create(:short_url_manager)
  end

  scenario "Short URL manager views the index of short_url requests and uses the pagination" do
    create :short_url_request, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-beards",
                          organisation_title: "Ministry of Beards",
                          created_at: 10.minutes.ago

    40.times do |n|
      create :short_url_request, from_path: "/from/path/#{n + 2}",
                            created_at: n.days.ago
    end

    visit "/"
    click_on "View pending requests"

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
                          route_type: "exact",
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
    expect(page).to have_content "exact"
    expect(page).to have_content "Because we really need to think about beards"
    expect(page).to have_content "gandalf@example.com"
  end

  scenario "Short URL manager shows the details of simialr fRUL requests" do
    create :short_url_request, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-beards",
                          reason: "Beards are now their own department",
                          contact_email: "gandalf@example.com",
                          created_at: Time.zone.parse("2014-01-01 12:00:00"),
                          organisation_title: "Ministry of Beards"
    create :short_url_request, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-facial-hair",
                          reason: "Facial Hair department is all about beards",
                          contact_email: "saruman@example.com",
                          created_at: Time.zone.parse("2013-01-01 12:00:00"),
                          organisation_title: "Ministry of Facial Hair"
    create :short_url_request, from_path: "/ministry-of-bears",
                          to_path: "/government/organisations/ministry-of-bears",
                          reason: "Because we really need to think about bears",
                          contact_email: "beorn@example.com",
                          created_at: Time.zone.parse("2013-11-01 12:00:00"),
                          organisation_title: "Ministry of Bears"

    visit short_url_requests_path

    click_on "Ministry of Beards"


    within '.other-requests' do
      # Don't have the main request in the other requests section
      expect(page).not_to have_content "Ministry of Beards"
      expect(page).not_to have_content "12:00pm, 1 January 2014"
      expect(page).not_to have_content "/ministry-of-beards"
      expect(page).not_to have_link "/government/organisations/ministry-of-beards", href: "http://www.dev.gov.uk/government/organisations/ministry-of-beards"
      expect(page).not_to have_content "Beards are now their own department"
      expect(page).not_to have_content "gandalf@example.com"

      # Do have a relevant other request
      expect(page).to have_content "Ministry of Facial Hair"
      expect(page).to have_content "12:00pm, 1 January 2013"
      expect(page).to have_content "/ministry-of-facial-hair"
      expect(page).to have_link "/government/organisations/ministry-of-facial-hair", href: "http://www.dev.gov.uk/government/organisations/ministry-of-facial-hair"
      expect(page).to have_content "Facial Hair department is all about beards"
      expect(page).to have_content "saruman@example.com"

      # Don't have an irrelevant other request
      expect(page).not_to have_content "Ministry of Bears"
      expect(page).not_to have_content "12:00pm, 1 Novemeber 2013"
      expect(page).not_to have_content "/ministry-of-bears"
      expect(page).not_to have_link "/government/organisations/ministry-of-bears", href: "http://www.dev.gov.uk/government/organisations/ministry-of-bears"
      expect(page).not_to have_content "Because we really need to think about bears"
      expect(page).not_to have_content "beorn@example.com"
    end
  end

  scenario "User without manage_short_urls permission sees no option to manage short_url requests" do
    login_as create(:user)
    visit "/"
    expect(page).to have_no_content('View pending requests')
  end
end
