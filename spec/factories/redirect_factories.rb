FactoryGirl.define do
  factory :redirect do
    sequence(:from_path) { |n| "/short-url-from-#{n}" }
    sequence(:to_path) { |n| "/short-url-to-#{n}" }
    route_type "exact"

    trait(:invalid) {
      to_path nil
    }
  end
end
