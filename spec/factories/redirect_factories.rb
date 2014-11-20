FactoryGirl.define do
  factory :redirect do
    sequence(:from_path) { |n| "/short-url-from-#{n}" }
    sequence(:to_path) { |n| "/short-url-to-#{n}" }

    trait(:invalid) {
      to_path nil
    }
  end

  factory :redirect_with_whitespace, class: 'Redirect' do
    sequence(:from_path) { |n| "/short-url-from-#{n} " }
    sequence(:to_path) { |n| "/short-url-to-#{n} " }
  end
end
