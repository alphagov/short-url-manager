Rails.application.routes.draw do

  get "/healthcheck" => Proc.new { [200, {}, ["OK"]] }
end
