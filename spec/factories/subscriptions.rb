FactoryBot.define do
  factory :subscription do
    plan_id { "MyString" }
    customer_id { "MyString" }
    user { nil }
    status { "MyString" }
    current_period_start { "2022-05-04 00:09:34" }
    current_periode_end { "2022-05-04 00:09:34" }
  end
end
