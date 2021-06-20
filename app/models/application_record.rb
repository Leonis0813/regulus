class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  MESSAGE_ABSENT = 'absent'.freeze
  MESSAGE_INVALID = 'invalid'.freeze

  STATE_WAITING = 'waiting'.freeze
  STATE_PROCESSING = 'processing'.freeze
  STATE_COMPLETED = 'completed'.freeze
  STATE_ERROR = 'error'.freeze
  DEFAULT_STATE = STATE_WAITING
  STATE_LIST = [STATE_WAITING, STATE_PROCESSING, STATE_COMPLETED, STATE_ERROR].freeze

  RESULT_UP = 'up'.freeze
  RESULT_DOWN = 'down'.freeze
  RESULT_RANGE = 'range'.freeze
  RESULT_LIST = [RESULT_UP, RESULT_DOWN, RESULT_RANGE].freeze

  def valid_period?
    errors.add(:from, MESSAGE_INVALID) unless from.is_a?(Date)
    errors.add(:to, MESSAGE_INVALID) unless to.is_a?(Date)

    return if errors.messages.include?(:from) or errors.messages.include?(:to)
    return if from < to

    errors.add(:from, MESSAGE_INVALID)
    errors.add(:to, MESSAGE_INVALID)
  end
end
