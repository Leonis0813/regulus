class Evaluation::TestDatum < ApplicationRecord
  validate :valid_period?
  validates :ground_truth,
            presence: {message: MESSAGE_ABSENT}
  validates :up_probability, :down_probability,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1,
              message: MESSAGE_INVALID,
            },
            allow_nil: true
  validates :ground_truth,
            inclusion: {in: RESULT_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  belongs_to :evaluation

  after_create do
    broadcast(
      'message_type' => 'create',
      'no' => evaluation.test_data.size,
      'from' => from.strftime('%F'),
      'to' => to.strftime('%F'),
    )
  end

  def import_result!(result_file)
    attribute = YAML.load_file(result_file)
    update!(up_probability: attribute['up'], down_probability: attribute['down'])
    broadcast('message_type' => 'update', 'prediction_result' => prediction_result)
  end

  private

  def prediction_result
    up_probability > down_probability ? RESULT_UP : RESULT_DOWN
  end

  def broadcast(updated_attribute = {})
    updated_attribute['id'] = "#{from.strftime('%Y%m%d')}-#{to.strftime('%Y%m%d')}"
    ActionCable.server.broadcast('evaluation_test_datum', updated_attribute)
  end
end
