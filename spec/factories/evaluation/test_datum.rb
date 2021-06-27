FactoryBot.define do
  factory :evaluation_test_datum, class: 'Evaluation::TestDatum' do
    from { '1000-01-01' }
    to { '1000-01-31' }
    ground_truth { 'up' }
  end
end
