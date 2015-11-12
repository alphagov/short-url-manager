require 'rails_helper'
require 'gds_api/test_helpers/publishing_api'

feature "Short URL manager responds to short URL requests" do
  include GdsApi::TestHelpers::PublishingApi
  include PublishingApiHelper

  background do
    stub_default_publishing_api_put
    login_as create(:user, permissions: ['signon', 'manage_short_urls'])
  end

  let!(:pending_request) do
    create(:short_url_request, from_path: "/ministry-of-beards",
                               to_path: "/government/organisations/ministry-of-beards",
                               reason: "Because we really need to think about beards",
                               contact_email: "gandalf@example.com",
                               created_at: Time.zone.parse("2014-01-01 12:00:00"),
                               organisation_slug: "ministry-of-beards",
                               organisation_title: "Ministry of Beards")
  end

  let!(:accepted_request) do
    create(:short_url_request, from_path: "/ministry-of-hair",
                               to_path: "/government/organisations/ministry-of-hair",
                               reason: "Hair enables beards to exist",
                               contact_email: "hairy@example.com",
                               created_at: Time.zone.parse("2014-01-01 12:00:00"),
                               organisation_slug: "ministry-of-hair",
                               organisation_title: "Ministry of Hair",
                               state: "accepted")
  end

  let!(:redirect_for_accepted_request) do
    create(:redirect, short_url_request: accepted_request,
                      from_path: accepted_request.from_path,
                      to_path: accepted_request.to_path)
  end

  let!(:other_organisation) do
    create(:organisation, title: "Department of Full English Breakfasts", slug: "full-english")
  end

  scenario "Short URL manager accepts a short URL request, and a redirect is created" do
    visit short_url_requests_path

    click_on "Ministry of Beards"
    click_on "Accept and create redirect"

    expect(page).to have_content("The redirect has been published")

    redirect_content_id = pending_request.reload.redirect.content_id
    assert_publishing_api_put_item('/ministry-of-beards', publishing_api_redirect_hash("/ministry-of-beards", "/government/organisations/ministry-of-beards", redirect_content_id))

    expect(ActionMailer::Base.deliveries.count).to eql 1
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eql ['gandalf@example.com']
    expect(mail.subject).to include 'Short URL request approved'
  end

  scenario "Short URL manager rejects a short URL request, giving a reason" do
    visit short_url_requests_path

    click_on "Ministry of Beards"
    click_on "Reject"
    fill_in "Reason", with: "Beards are soo last season."
    click_on "Reject"

    expect(page).to have_content("The short URL request has been rejected, and the requester has been notified")

    expect(ActionMailer::Base.deliveries.count).to eql 1
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eql ['gandalf@example.com']
    expect(mail.subject).to include 'Short URL request denied'
    expect(mail).to have_body_content "Beards are soo last season."
  end

  scenario "Short URL manager edits a short URL" do
    visit list_short_urls_path

    click_on "Ministry of Hair"
    click_on "Edit"

    fill_in "Target URL", with: "/government/organisations/ministry-of-long-hair"
    select "Department of Full English Breakfasts", from: "Organisation"
    click_on "Update"

    expect(page).to have_content("Your edit was successful.")
    accepted_request.reload
    expect(accepted_request.organisation_slug).to eql("full-english")
    expect(accepted_request.organisation_title).to eql("Department of Full English Breakfasts")
    assert_publishing_api_put_item('/ministry-of-hair', publishing_api_redirect_hash("/ministry-of-hair", "/government/organisations/ministry-of-long-hair", redirect_for_accepted_request.content_id))
  end
end
