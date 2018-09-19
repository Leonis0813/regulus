class Analysis < ActiveRecord::Base
  validates :from, :presence => {:message => 'absent'}
  validates :to, :presence => {:message => 'absent'}
  validate :valid_period?
  validates :batch_size, :numericality => {:only_integer => true, :greater_than => 0}
  validates :state, :inclusion => {:in => %w[ processing completed ]}

  private

  def valid_period?
    return if errors.messages.include?(:from) or errors.messages.include?(:to)

    [[:from, from], [:to, to]].each do |key, value|
      begin
        Time.parse(value)
      rescue ArgumentError => e
        errors.add(key, 'invalid')
      end
    end

    return if errors.messages.include?(:from) or errors.messages.include?(:to)

    unless Time.parse(from) < Time.parse(to)
      errors.add(:from, 'invalid')
      errors.add(:to, 'invalid')
    end
  end
end
