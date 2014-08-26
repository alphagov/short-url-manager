Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :short_url_requests do
    member do
      post "accept" => "short_url_requests#accept"
      get "new_rejection" => "short_url_requests#new_rejection"
      post "reject" => "short_url_requests#reject"
    end
  end

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }

  if Rails.env.development?
    get "/styleguide" => "govuk_admin_template/style_guide#index"
  end
end
