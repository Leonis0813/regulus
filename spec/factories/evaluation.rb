FactoryBot.define do
  factory :evaluation do
    evaluation_id { '0' * 32 }
    model { 'model.zip' }
    from { '1000-01-01' }
    to { '1000-12-31' }
  end
end
