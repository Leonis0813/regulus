class Prediction < ActiveRecord::Base
  validate :valid_period?
  validates :model, format: {with: /\.zip\z/, message: 'invalid'}
  validates :result,
            inclusion: {in: %w[up down range], message: 'invalid'},
            allow_nil: true
  validates :state, inclusion: {in: %w[processing completed error], message: 'invalid'}

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
