FactoryGirl.define do
  factory :paper do
    title "Example title"
    scale 1
    deadline Time.at(2.years.from_now).to_s
  end
end
