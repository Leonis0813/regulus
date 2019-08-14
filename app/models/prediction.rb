class Prediction < ApplicationRecord
  PAIR_LIST = Analysis::PAIR_LIST
  MEANS_MANUAL = 'manual'.freeze
  MEANS_AUTO = 'auto'.freeze
  MEANS_LIST = [MEANS_MANUAL, MEANS_AUTO].freeze
  RESULT_LIST = %w[up down range].freeze
  STATE_PROCESSING = Analysis::STATE_PROCESSING
  STATE_COMPLETED = Analysis::STATE_COMPLETED
  STATE_ERROR = Analysis::STATE_ERROR
  STATE_LIST = Analysis::STATE_LIST

  validate :valid_period?
  validates :prediction_id, :model, :state,
            presence: {message: 'absent'}
  validates :prediction_id,
            format: {with: /^[0-9a-zA-Z]{32}$/, message: 'invalid'},
            allow_nil: true
  validates :model,
            format: {with: /\.zip\z/, message: 'invalid'},
            allow_nil: true
  validates :pair,
            inclusion: {in: PAIR_LIST, message: 'invalid'},
            allow_nil: true
  validates :means,
            inclusion: {in: MEANS_LIST, message: 'invalid'},
            allow_nil: true
  validates :result,
            inclusion: {in: RESULT_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'},
            allow_nil: true

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
