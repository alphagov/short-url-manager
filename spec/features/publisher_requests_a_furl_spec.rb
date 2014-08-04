require 'rails_helper'

feature "As a publisher, I can request a FURL" do
  background do
    create :organisation, title: 'Ministry of Magic', slug: 'ministry-of-magic'
    create :organisation, title: 'Ministry of Beards', slug: 'ministry-of-beards'
    create :user, email: "furl-manager-1@example.com", permissions: ['signon', 'manage_furls']
    login_as create(:user, permissions: ['signon', 'request_furls'], name: "Gandalf", email: "gandalf@example.com", organisation_slug: "ministry-of-magic")
  end

  scenario "Publisher requests a furl, and furl managers are notified" do
    visit "/"
    click_on "Request a new friendly url"

    expect(page).to have_field "Contact email", with: "gandalf@example.com"
    expect(page).to have_select "Organisation", selected: "Ministry of Magic"

    fill_in "From",          with: from_path = "/some-friendly-url"
    fill_in "To",            with: to_path   = "/government/publications/some-random-publication"
    select "Ministry of Beards", from: "Organisation"
    fill_in "Reason",        with: reason    = "Because of the wombats"
    fill_in "Contact email", with: email     = "gandalf@example.com"

    click_on "Make this request"

    expect(page).to have_content "Your request has been made."

    furl_request = FurlRequest.last
    expect(furl_request.from).to               eql from_path
    expect(furl_request.to).to                 eql to_path
    expect(furl_request.reason).to             eql reason
    expect(furl_request.contact_email).to      eql email
    expect(furl_request.organisation_slug).to  eql 'ministry-of-beards'
    expect(furl_request.organisation_title).to eql 'Ministry of Beards'

    expect(ActionMailer::Base.deliveries.count).to eql 1
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eql ['furl-manager-1@example.com']
    expect(mail.subject).to include 'Furl request'
  end

  scenario "User without request_furls permission sees no option to request a furl" do
    login_as create(:user, permissions: ['signon'])
    visit "/"
    expect(page).to have_no_content('Request a new friendly url')
  end
end
