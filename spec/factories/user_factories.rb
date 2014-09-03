FactoryGirl.define do
  factory :user do
    permissions ['signon']
    sequence(:email) { |n| "user-#{n}@example.com" }
  end

  factory :short_url_requester, parent: :user do
    permissions ['signon', 'request_short_urls']
  end

  factory :short_url_manager, parent: :user do
    permissions ['signon', 'manage_short_urls']
  end
end
