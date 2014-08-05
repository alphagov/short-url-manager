require 'rails_helper'

feature "fURL manager finds information on furl requests" do
  background do
    login_as create(:user, permissions: ['signon', 'manage_furls'])
    create :furl_request, from: "/ministry-of-beards",
                          to: "/government/organisations/ministry-of-beards",
                          organisation_title: "Ministry of Beards",
                          created_at: 10.minutes.ago

    40.times do |n|
      create :furl_request, from: "/from/path/#{n+2}",
                            created_at: n.days.ago
    end
  end

  scenario "fURL manager views the index of furl requests and uses the pagination" do
    visit "/"
    click_on "Manage friendly URL requests"

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

  scenario "User without manage_furls permission sees no option to manage furls" do
    login_as create(:user, permissions: ['signon'])
    visit "/"
    expect(page).to have_no_content('Manage friendly URL requests')
  end
end
