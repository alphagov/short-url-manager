FactoryGirl.define do
  factory :organisation do
    sequence(:slug) { |n| "organisation-#{n}" }
    sequence(:title) { |n| "Organisation #{n}" }
  end
end
