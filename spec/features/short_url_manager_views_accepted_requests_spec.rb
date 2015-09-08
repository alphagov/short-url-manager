require 'rails_helper'

feature "Short URL manager views accepted short url requests" do
  background do
    login_as create(:user, permissions: ['signon', 'manage_short_urls'])
  end

  scenario "Short URL manager the index of short_url requests" do
    create :short_url_request, :accepted, from_path: "/ministry-of-beards",
                          to_path: "/government/organisations/ministry-of-beards",
                          organisation_title: "Ministry of Beards",
                          created_at: 10.minutes.ago

    create :short_url_request, :pending, from_path: "/from/pending"
    create :short_url_request, :rejected, from_path: "/from/rejected"

    40.times do |n|
      create :short_url_request, :accepted, from_path: "/from/path/#{n+2}",
                            created_at: n.days.ago
    end

    visit "/"
    click_on "View live short URLs"

    expect(page).to have_content "/ministry-of-beards"
    expect(page).to have_content "/government/organisations/ministry-of-beards"
    expect(page).to have_content "Ministry of Beards"

    expect(page).to have_no_content "/from/pending"
    expect(page).to have_no_content "/from/rejected"

    expect(page).to have_content "/from/path/2"
    expect(page).to have_content "/from/path/40"
    expect(page).to have_content "/from/path/41"
  end
end
