Rails.application.routes.draw do
  root "dashboard#dashboard"

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }
end
