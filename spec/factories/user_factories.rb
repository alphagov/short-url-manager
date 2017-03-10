FactoryGirl.define do
  factory :user do
    permissions ['signin']
    sequence(:email) { |n| "user-#{n}@example.com" }
  end

  factory :short_url_requester, parent: :user do
    permissions %w(signin request_short_urls)
  end

  factory :short_url_manager, parent: :user do
    permissions %w(signin manage_short_urls)
  end

  factory :short_url_requester_and_manager, parent: :user do
    permissions %w(signin request_short_urls manage_short_urls)
  end
end
