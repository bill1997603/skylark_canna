FactoryGirl.define do
  factory :option do
    description "Example description"
    problem

    trait :right do
      right true
    end
  end
end
