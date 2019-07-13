class Prediction < ActiveRecord::Base
  RESULT_LIST = %w[up down range].freeze
  MEANS_LIST = %w[manual auto].freeze

  validate :valid_period?
  validates :model, :means, :state,
            presence: {message: 'absent'}
  validates :model,
            format: {with: /\.zip\z/, message: 'invalid'}
  validates :pair,
            inclusion: {in: Analysis::PAIR_LIST, message: 'invalid'},
            allow_nil: true
  validates :means,
            inclusion: {in: MEANS_LIST, message: 'invalid'}
  validates :result,
            inclusion: {in: RESULT_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: Analysis::STATE_LIST, message: 'invalid'}

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
