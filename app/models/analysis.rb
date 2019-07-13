class Analysis < ActiveRecord::Base
  DEFAULT_PAIR = 'USDJPY'.freeze
  PAIR_LIST = %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY].freeze
  STATE_LIST = %w[processing completed error].freeze

  validate :valid_period?
  validates :batch_size, :pair, :state,
            presence: {message: 'absent'}
  validates :batch_size,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
  validates :pair,
            inclusion: {in: PAIR_LIST, message: 'invalid'}
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'}

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
