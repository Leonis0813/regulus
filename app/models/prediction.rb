class Prediction < ActiveRecord::Base
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
  validates :model, :means, :state,
            presence: {message: 'absent'}
  validates :model,
            format: {with: /\.zip\z/, message: 'invalid'}
  validates :pair,
            inclusion: {in: PAIR_LIST, message: 'invalid'},
            allow_nil: true
  validates :means,
            inclusion: {in: MEANS_LIST, message: 'invalid'}
  validates :result,
            inclusion: {in: RESULT_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'}

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
