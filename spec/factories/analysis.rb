FactoryBot.define do
  factory :analysis do
    from { '2000-01-01 00:00:00' }
    to { '2000-01-01 23:59:59' }
    pair { 'USDJPY' }
    batch_size { 100 }
    state { 'processing' }
  end
end
