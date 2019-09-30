class Analysis < ApplicationRecord
  DEFAULT_PAIR = 'USDJPY'.freeze
  PAIR_LIST = %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY].freeze
  STATE_PROCESSING = 'processing'.freeze
  STATE_COMPLETED = 'completed'.freeze
  STATE_ERROR = 'error'.freeze
  STATE_LIST = [STATE_PROCESSING, STATE_COMPLETED, STATE_ERROR].freeze

  validate :valid_period?
  validates :batch_size, :pair, :state,
            presence: {message: 'absent'}
  validates :batch_size,
            numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
            allow_nil: true
  validates :pair,
            inclusion: {in: PAIR_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'},
            allow_nil: true

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
