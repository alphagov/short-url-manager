FactoryGirl.define do
  factory :short_url_request do
    sequence(:from_path) { |n| "/short-url-request-from-path-#{n}" }
    sequence(:to_path) { |n| "/short-url-request-to-path-#{n}" }
    sequence(:reason) { |n| "Short URL request reason #{n}" }
    sequence(:contact_email) { |n| "short-url-requester-#{n}@example.com" }
    sequence(:organisation_slug) { |n| "organisation-#{n}" }
    sequence(:organisation_title) { |n| "Organisation #{n}" }
    association :requester, factory: :short_url_requester

    after(:build) do |short_url_request|
      create(:organisation, slug: short_url_request.organisation_slug, title: short_url_request.organisation_title)
    end

    trait :pending do
      state 'pending'
    end
    trait :accepted do
      state 'accepted'

      after(:create) do |request|
        request.redirect = create(:redirect,
                                  from_path: request.from_path,
                                  to_path: request.to_path)
      end
    end
    trait :rejected do
      state 'rejected'
    end
  end
end
