class Evaluation::TestDatum < ApplicationRecord
  validate :valid_period?
  validates :ground_truth,
            presence: {message: MESSAGE_ABSENT}
  validates :prediction_result, :ground_truth,
            inclusion: {in: RESULT_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  belongs_to :evaluation

  after_create do

  end

  def import_result!(result_file)
    attribute = YAML.load_file(result_file)
    result = attribute['up'] > attribute['down'] ? RESULT_UP : RESULT_DOWN
    update!(prediction_result: result)
  end

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
