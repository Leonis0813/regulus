class Evaluation::TestDatum < ApplicationRecord
  validate :valid_period?
  validates :ground_truth,
            presence: {message: MESSAGE_ABSENT}
  validates :prediction_result, :ground_truth,
            inclusion: {in: RESULT_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  belongs_to :evaluation

  private

  def valid_period?
    errors.add(:from, MESSAGE_INVALID) unless from
    errors.add(:to, MESSAGE_INVALID) unless to

    return if errors.messages.include?(:from) or errors.messages.include?(:to)
    return if from < to

    errors.add(:from, MESSAGE_INVALID)
    errors.add(:to, MESSAGE_INVALID)
  end
end
