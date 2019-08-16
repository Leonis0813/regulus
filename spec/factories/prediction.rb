FactoryBot.define do
  factory :prediction do
    prediction_id { '0' * 32 }
    model { 'model.zip' }
    from {}
    to {}
    pair {}
    result {}
    state { 'processing' }
  end
end
