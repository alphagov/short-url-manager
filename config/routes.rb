Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :furl_requests
  post "/furl_requests/:id/accept" => "furl_requests#accept", as: "accept_furl_request"

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }

  if Rails.env.development?
    get "/styleguide" => "govuk_admin_template/style_guide#index"
  end
end
