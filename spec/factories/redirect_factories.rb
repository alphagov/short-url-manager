FactoryBot.define do
  factory :redirect do
    sequence(:from_path) { |n| "/short-url-from-#{n}" }
    sequence(:to_path) { |n| "/short-url-to-#{n}" }
    route_type { "exact" }
    segments_mode { "ignore" }

    trait(:invalid) do
      to_path { nil }
    end
  end
end
