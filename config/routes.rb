Rails.application.routes.draw do
  root "dashboard#dashboard"

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }

  if Rails.env.development?
    get "/styleguide" => "govuk_admin_template/style_guide#index"
  end
end
