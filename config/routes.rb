Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :furl_requests
  post "/furl_requests/:id/accept" => "furl_requests#accept", as: "accept_furl_request"
  get "/furl_requests/:id/new_rejection" => "furl_requests#new_rejection", as: "new_rejection_furl_request"
  post "/furl_requests/:id/reject" => "furl_requests#reject", as: "reject_furl_request"

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }

  if Rails.env.development?
    get "/styleguide" => "govuk_admin_template/style_guide#index"
  end
end
