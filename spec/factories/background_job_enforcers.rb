FactoryBot.define do
  factory :background_job_enforcer do
    job_type { Faker::Lorem.word }
    date { Time.zone.today }
  end
end
