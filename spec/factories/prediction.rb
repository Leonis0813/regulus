FactoryBot.define do
  factory :prediction do
    model { 'model.zip' }
    from {}
    to {}
    pair {}
    result {}
    state { 'processing' }
  end
end
