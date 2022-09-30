module SSOFeatureHelper
  include Warden::Test::Helpers

  def login_as(user)
    user.save! unless user.persisted?
    GDS::SSO.test_user = user
  end

  def logout
    GDS::SSO.test_user = nil
  end
end

module SSOControllerHelper
  include SSOFeatureHelper

  def login_as(user)
    super # SSOFeatureHelper
    request.env["warden"] = double(
      authenticate!: true,
      authenticated?: true,
      user:,
    )
  end

  def logout
    super # SSOFeatureHelper
    request.env["warden"] = double(
      authenticate!: false,
      authenticated?: false,
      user: nil,
    )
  end

  def expect_not_authorised(http_method, action, params = {})
    send(http_method, action, params:)
    expect(response.status).to eql 403
  end
end

RSpec.configuration.include SSOControllerHelper, type: :controller
RSpec.configuration.include SSOFeatureHelper, type: :feature
