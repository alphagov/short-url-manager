GDS::SSO.config do |config|
  config.user_model   = 'User'
  config.oauth_id     = ENV['OAUTH_ID']
  config.oauth_secret = ENV['OAUTH_SECRET']
  config.oauth_root_url = Plek.current.find('signon')
end


if Rails.env.development?
  # In development, if we want to be able to test features that require permissions
  # then we need to override the default permissions for the dummy user inserted by
  # GDS::SSO in the mock_bearer_token strategy.
  #
  # The easiest way to do this is just to override the GDS::SSO test user with a
  # new user we create here.
  #
  GDS::SSO.test_user = User.find_or_create_by(email: 'user@test.example').tap do |u|
    u.name = 'Test User'
    u.permissions = %w(signin manage_short_urls request_short_urls)
    u.save!
  end
end
