Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :furl_requests do
    member do
      post "accept" => "furl_requests#accept"
      get "new_rejection" => "furl_requests#new_rejection"
      post "reject" => "furl_requests#reject"
    end
  end

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }

  if Rails.env.development?
    get "/styleguide" => "govuk_admin_template/style_guide#index"
  end
end
