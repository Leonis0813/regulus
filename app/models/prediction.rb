class Prediction < ActiveRecord::Base
  validate :valid_period?
  validates :result, :inclusion => {:in => %w[ up down range ], :message => 'invalid'}
  validates :state, :inclusion => {:in => %w[ processing completed ], :message => 'invalid'}

  private

  def valid_period?
    [
      [from, :from],
      [to, :to],
    ].each do |time, attribute|
      begin
        Time.parse(time) if time
      rescue ArgumentError => e
        errors.add(attribute, 'invalid')
      end
    end

    return if errors.messages.include?(:from) or errors.messages.include?(:to)

    unless from < to
      errors.add(:from, 'invalid')
      errors.add(:to, 'invalid')
    end
  end
end
