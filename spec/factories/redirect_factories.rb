FactoryGirl.define do
  factory :redirect do
    sequence(:from_path) { |n| "/furl-from-#{n}" }
    sequence(:to_path) { |n| "/furl-to-#{n}" }

    trait(:invalid) {
      to_path nil
    }
  end
end
