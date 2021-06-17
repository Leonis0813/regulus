class Prediction < ApplicationRecord
  MEANS_MANUAL = 'manual'.freeze
  MEANS_AUTO = 'auto'.freeze
  MEANS_LIST = [MEANS_MANUAL, MEANS_AUTO].freeze

  validate :valid_period?
  validates :prediction_id, :model, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :prediction_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :model,
            format: {with: /\.zip\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :means,
            inclusion: {in: MEANS_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :result,
            inclusion: {in: RESULT_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  belongs_to :analysis

  after_initialize if: :new_record? do |prediction|
    prediction.prediction_id = SecureRandom.hex
    prediction.state = DEFAULT_STATE
  end

  def set_analysis!
    metadata = YAML.load_file(Rails.root.join('scripts/tmp/metadata.yml'))
    analysis = Analysis.find_by(analysis_id: metadata['analysis_id'])
    raise StandardError if analysis.nil?

    update!(analysis: analysis)
    broadcast('pair' => analysis.pair)
  end

  def import_result!(result_file)
    attribute = YAML.load_file(result_file)
    result = attribute['up'] > attribute['down'] > RESULT_UP : RESULT_DOWN
    update!(attribute.slice('from', 'to').merge(result: result))
    updated_attribute = {
      'result' => result,
      'from' => from.strftime('%Y/%m/%d %T'),
      'to' => to.strftime('%Y/%m/%d %T'),
    }
    broadcast(updated_attribute)
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    updated_attribute = {
      'state' => state,
      'performed_at' => performed_at.strftime('%Y/%m/%d %T'),
    }
    broadcast(updated_attribute)
  end

  def completed!
    update!(state: STATE_COMPLETED)
    broadcast(attributes.slice('state'))
  end

  def failed!
    update!(state: STATE_ERROR)
    broadcast(attributes.slice('state'))
  end

  private

  def broadcast(updated_attribute = {})
    updated_attribute['prediction_id'] = prediction_id
    ActionCable.server.broadcast('prediction', updated_attribute)
  end

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
