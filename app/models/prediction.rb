class Prediction < ActiveRecord::Base
  validate :valid_period?
  validates :result, :inclusion => {:in => %w[ up down range ], :message => 'invalid'}, :allow_nil => true
  validates :state, :inclusion => {:in => %w[ processing completed ], :message => 'invalid'}

  private

  def valid_period?
    return unless from and to

    unless from < to
      errors.add(:from, 'invalid')
      errors.add(:to, 'invalid')
    end
  end
end
