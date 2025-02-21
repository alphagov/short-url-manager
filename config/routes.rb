Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :short_url_requests do
    member do
      post "accept" => "short_url_requests#accept"
      get "new_rejection" => "short_url_requests#new_rejection"
      get "remove" => "short_url_requests#remove"
      post "reject" => "short_url_requests#reject"
    end
  end
  get "list_short_urls" => "short_url_requests#list_short_urls"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::Mongoid,
    GovukHealthcheck::SidekiqRedis,
  )

  mount GovukPublishingComponents::Engine, at: "/component-guide"
  get "/styleguide" => "govuk_admin_template/style_guide#index"
end
