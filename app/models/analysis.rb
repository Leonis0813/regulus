class Analysis < ActiveRecord::Base
  DEFAULT_PAIR = 'USDJPY'.freeze
  PAIRS = %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY].freeze
  STATES = %w[processing completed error].freeze

  validate :valid_period?
  validates :batch_size, :pair, :state,
            presence: {message: 'absent'}
  validates :batch_size,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
  validates :pair,
            inclusion: {in: PAIRS, message: 'invalid'}
  validates :state,
            inclusion: {in: STATES, message: 'invalid'}

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
