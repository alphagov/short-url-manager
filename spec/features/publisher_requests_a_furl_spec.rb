require 'rails_helper'

feature "As a publisher, I can request a FURL" do
  background do
    login_as create(:user, permissions: ['signon', 'request_furls'])
  end

  scenario "Publisher requests a furl" do
    visit "/"
    click_on "Request a new friendly url"
    fill_in "From",          with: from_path = "/some-friendly-url"
    fill_in "To",            with: to_path   = "/government/publications/some-random-publication"
    fill_in "Reason",        with: reason    = "Because of the wombats"
    fill_in "Contact email", with: email     = "publisher@example.com"

    click_on "Make this request"

    expect(page).to have_content "Your request has been made."

    furl_request = FurlRequest.last
    expect(furl_request.from).to          eql from_path
    expect(furl_request.to).to            eql to_path
    expect(furl_request.reason).to        eql reason
    expect(furl_request.contact_email).to eql email
  end

  scenario "Non-'furl requester' sees no option to request a furl" do
    login_as create(:user, permissions: ['signon'])
    visit "/"
    expect(page).to have_no_content('Request a new friendly url')
  end
end
