require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

feature "Short URL manager responds to short URL requests" do
  include GdsApi::TestHelpers::PublishingApiV2
  include PublishingApiHelper

  background do
    stub_any_publishing_api_call
    login_as create(:short_url_manager)
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
                               route_type: "exact",
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
    assert_publishing_api_put_content(redirect_content_id)

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

    target_url = "/government/organisations/ministry-of-long-hair"
    fill_in "Target URL", with: target_url
    select "Department of Full English Breakfasts", from: "Organisation"
    click_on "Update"

    expect(page).to have_content("Your edit was successful.")
    accepted_request.reload
    expect(accepted_request.organisation_slug).to eql("full-english")
    expect(accepted_request.organisation_title).to eql("Department of Full English Breakfasts")
    assert_publishing_api_put_content(redirect_for_accepted_request.content_id,
                                      publishing_api_redirect_hash('/ministry-of-hair',
                                                                   target_url,
                                                                   accepted_request.redirect.content_id,
                                                                   accepted_request.route_type))
    # publish has already been called once for the original redirect.
    assert_publishing_api_publish(redirect_for_accepted_request.content_id, nil, 2)
  end

  context "when presented with a request that matches an existing redirect short URL" do
    let!(:pending_request_for_existing_short_url) do
      create(:short_url_request,
             :pending,
             organisation_title: "Ministry of Hair",
             from_path: "/ministry-of-hair",
      )
    end

    scenario "Short URL manager is shown a warning message" do
      visit short_url_requests_path

      click_on "Ministry of Hair"

      within("#existing-redirect-warning") do
        expect(page).to have_content accepted_request.from_path
        expect(page).to have_content accepted_request.to_path
        expect(page).to have_content "Accepting this request will overwrite that."
      end
    end
  end
end
