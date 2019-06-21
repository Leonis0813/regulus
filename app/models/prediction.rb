class Prediction < ActiveRecord::Base
  RESULTS = %w[up down range]

  validate :valid_period?
  validates :model,
            presence: {message: 'absent'},
            format: {with: /\.zip\z/, message: 'invalid'}
  validates :pair,
            inclusion: {in: Analysis::PAIRS, message: 'invalid'}
  validates :result,
            inclusion: {in: RESULTS, message: 'invalid'}
  validates :state,
            inclusion: {in: Analysis::STATES, message: 'invalid'}

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
