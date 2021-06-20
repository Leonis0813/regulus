# coding: utf-8

shared_context 'ActionCableのモックを作成' do
  before do
    @called = false
    allow_any_instance_of(ActionCable::Server::Base).to receive(:broadcast) do
      @called = true
    end
  end
end

shared_examples 'バリデーションエラーにならないこと' do
  it_is_asserted_by { @object.valid? }
end

shared_examples 'エラーメッセージが正しいこと' do |expected_error|
  it "#{expected_error.keys.join(',')}がエラーになっていること" do
    is_asserted_by { @object.errors.messages.keys.sort == expected_error.keys.sort }
  end

  expected_error.each do |key, message|
    it "#{key}のエラーメッセージが#{message}であること" do
      is_asserted_by { @object.errors.messages[key] == [message] }
    end
  end
end

shared_examples '正常な値を指定した場合のテスト' do |valid_attribute|
  CommonHelper.generate_test_case(valid_attribute).each do |attribute|
    it "#{attribute}を指定した場合、エラーにならないこと" do
      object = build(described_class.name.downcase.to_sym, attribute)
      object.validate
      is_asserted_by { object.errors.empty? }
    end
  end
end

shared_examples '必須パラメーターがない場合のテスト' do |absent_keys|
  absent_keys.each do |absent_key|
    it "#{absent_key}がない場合、absentエラーになること" do
      attribute = build(described_class.name.downcase.to_sym)
                  .attributes.except(absent_key.to_s)
      object = described_class.new(attribute)
      object.validate
      is_asserted_by { object.errors.present? }
      is_asserted_by { object.errors.messages[absent_key].include?('absent') }
    end
  end
end

shared_examples '不正な値を指定した場合のテスト' do |invalid_attribute|
  CommonHelper.generate_test_case(invalid_attribute).each do |attribute|
    it "#{attribute}を指定した場合、エラーになること" do
      object = build(described_class.name.downcase.to_sym, attribute)
      object.validate
      is_asserted_by { object.errors.present? }

      attribute.keys.each do |invalid_key|
        is_asserted_by { object.errors.messages[invalid_key].include?('invalid') }
      end
    end
  end
end

shared_examples '不正な期間を指定した場合のテスト' do |invalid_period|
  CommonHelper.generate_test_case(invalid_period).each do |attribute|
    it "#{attribute}を指定した場合、エラーとなること" do
      object = build(described_class.name.downcase.to_sym, attribute)
      object.validate
      is_asserted_by { object.errors.messages[:from].include?('invalid') }
      is_asserted_by { object.errors.messages[:to].include?('invalid') }
    end
  end
end
