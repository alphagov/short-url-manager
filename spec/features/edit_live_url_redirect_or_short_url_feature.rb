require "rails_helper"

RSpec.feature "Edit live URL redirect or Short URL" do
  include GdsApi::TestHelpers::PublishingApi
  include PublishingApiHelper

  scenario "Edit redirect to keep segments" do
    given_i_can_create_and_approve_requests_using_advanced_options
    and_an_accepted_short_url_request_exists_that_discards_segments
    when_i_login
    and_i_edit_the_redirect
    and_i_choose_to_keep_segments
    and_i_update_the_redirect_url
    then_i_am_alerted_that_my_edit_was_successful
    and_the_redirect_is_published
  end

  def given_i_can_create_and_approve_requests_using_advanced_options
    @user = create(:short_url_manager_with_advanced_options)
  end

  def and_an_accepted_short_url_request_exists_that_discards_segments
    @short_url_request = create(
      :short_url_request,
      :accepted,
      segments_mode: "ignore",
    )
  end

  def when_i_login
    login_as @user
  end

  def and_i_edit_the_redirect
    visit edit_short_url_request_path(@short_url_request)
  end

  def and_i_choose_to_keep_segments
    select "Keep", from: "Segments"
  end

  def and_i_update_the_redirect_url
    click_button "Update"
  end

  def then_i_am_alerted_that_my_edit_was_successful
    expect(page).to have_text("Your edit was successful")
  end

  def and_the_redirect_is_published
    assert_publishing_api_put_content(
      @short_url_request.redirect.content_id,
      publishing_api_redirect_hash(
        @short_url_request.redirect.from_path,
        @short_url_request.redirect.to_path,
        @short_url_request.redirect.route_type,
        "preserve",
      ),
    )

    assert_publishing_api_publish(
      @short_url_request.redirect.content_id,
      nil,
      3, # publish has already been called twice for the original redirect
    )
  end
end
