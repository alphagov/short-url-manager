FactoryGirl.define do
  factory :user do
    permissions ['signon']
    sequence(:email) { |n| "user-#{n}@example.com" }
  end

  factory :furl_requester, parent: :user do
    permissions ['signon', 'request_furls']
  end

  factory :furl_manager, parent: :user do
    permissions ['signon', 'manage_furls']
  end
end
