FactoryGirl.define do
  factory :problem do
    description "Example description"
    form 1

    transient do
      options_count 4
    end

    after(:build) do |problem, evaluator|
      problem.options << build_list(:option, evaluator.options_count, problem: problem)
    end

    before(:create) do |problem, evaluator|
      problem.options << build_list(:option, evaluator.options_count, problem: problem)
      problem.options.last.right = true
    end
  end
end
