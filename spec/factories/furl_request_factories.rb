FactoryGirl.define do
  factory :furl_request do
    sequence(:from_path) { |n| "/furl-request-from-path-#{n}" }
    sequence(:to_path) { |n| "/furl-request-to-path-#{n}" }
    sequence(:reason) { |n| "Furl request reason #{n}" }
    sequence(:contact_email) { |n| "furl-requster-#{n}@example.com" }
    sequence(:organisation_slug) { |n| "organisation-#{n}" }
    sequence(:organisation_title) { |n| "Organisation #{n}" }
    association :requester, factory: :furl_requester

    trait :pending do
      state 'pending'
    end
    trait :accepted do
      state 'accepted'
    end
    trait :rejected do
      state 'rejected'
    end
  end
end
