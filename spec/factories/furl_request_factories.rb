FactoryGirl.define do
  factory :furl_request do
    sequence(:from) { |n| "/furl-request-from-#{n}" }
    sequence(:to) { |n| "/furl-request-to-#{n}" }
    sequence(:reason) { |n| "Furl request reason #{n}" }
    sequence(:contact_email) { |n| "furl-requster-#{n}@example.com" }
    sequence(:organisation_slug) { |n| "organisation-#{n}" }
    sequence(:organisation_title) { |n| "Organisation #{n}" }
    association :requester, factory: :furl_requester
  end
end
