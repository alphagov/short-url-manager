FactoryGirl.define do
  factory :furl do
    sequence(:from) { |n| "/furl-from-#{n}" }
    sequence(:to) { |n| "/furl-to-#{n}" }

    trait(:invalid) {
      to nil
    }
  end
end
