require 'rails_helper'

feature "As a publisher, I can request a short URL" do
  background do
    create :organisation, title: 'Ministry of Magic', slug: 'ministry-of-magic'
    create :organisation, title: 'Ministry of Beards', slug: 'ministry-of-beards'
    create :user, email: "short-url-manager-1@example.com", permissions: ['signon', 'manage_short_urls']
    login_as create(:user, permissions: ['signon', 'request_short_urls'], name: "Gandalf", email: "gandalf@example.com", organisation_slug: "ministry-of-magic")
  end

  scenario "Publisher requests a short_url, and short_url managers are notified" do
    visit "/"
    click_on "Request a new short URL"

    expect(page).to have_select "Organisation", selected: "Ministry of Magic"

    fill_in "From",          with: from_path = "/some-friendly-url"
    fill_in "To",            with: to_path   = "/government/publications/some-random-publication"
    select "Ministry of Beards", from: "Organisation"
    fill_in "Reason",        with: reason    = "Because of the wombats"

    click_on "Make this request"

    expect(page).to have_content "Your request has been made."

    short_url_request = ShortUrlRequest.last
    expect(short_url_request.from_path).to          eql from_path
    expect(short_url_request.to_path).to            eql to_path
    expect(short_url_request.reason).to             eql reason
    expect(short_url_request.contact_email).to      eql 'gandalf@example.com'
    expect(short_url_request.organisation_slug).to  eql 'ministry-of-beards'
    expect(short_url_request.organisation_title).to eql 'Ministry of Beards'

    expect(ActionMailer::Base.deliveries.count).to eql 1
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eql ['short-url-manager-1@example.com']
    expect(mail.subject).to include 'Short URL request'
  end

  scenario "User without request_short_urls permission sees no option to request a short_url" do
    login_as create(:user, permissions: ['signon'])
    visit "/"
    expect(page).to have_no_content('Request a new short URL')
  end
end
