class Analysis < ActiveRecord::Base
  validate :valid_period?
  validates :batch_size, numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
  validates :state, inclusion: {in: %w[processing completed], message: 'invalid'}

  private

  def valid_period?
    errors.add(:from, 'invalid') unless from
    errors.add(:to, 'invalid') unless to

    return if errors.messages.include?(:from) or errors.messages.include?(:to)
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
