class Evaluation < ApplicationRecord
  validate :valid_period?
  validates :evaluation_id, :model, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :model,
            format: {with: /\.zip\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :log_loss,
            numericality: {greater_than_or_equal: 0, message: MESSAGE_INVALID},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  belongs_to :analysis
  has_many :test_data, dependent: :destroy

  after_initialize if: :new_record? do |evaluation|
    evaluation.evaluation_id = SecureRandom.hex
    evaluation.state = DEFAULT_STATE
  end

  after_create :broadcast

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    broadcast(performed_at: performed_at.strftime('%Y/%m/%d %T'))
  end

  def complete!
    update!(state: STATE_COMPLETED)
    broadcast
  end

  def failed!
    update!(state: STATE_ERROR)
    broadcast
  end

  def set_analysis!
    metadata = YAML.load_file(Rails.root.join('scripts/tmp/metadata.yml'))
    analysis = Analysis.find_by(analysis_id: metadata['analysis_id'])
    raise StandardError if analysis.nil?

    update!(analysis: analysis)
    broadcast(pair: analysis.pair)
  end

  def create_test_data!
    weekdays = (from..to).to_a.reject {|date| date.saturday? or date.sunday? }

    weekdays.size.times.each do |i|
      next unless (i + 21) < weekdays.size

      from = weekdays[i]
      to = weekdays[i + 19]
      values = Zosma::CandleStick.daily.between(to, to + 2).where(pair: analysis.pair)
      ground_truth = values.first.open < values.last.open ? RESULT_UP : RESULT_DOWN
      test_data.create!(from: from, to: to, ground_truth: ground_truth)
    end
  end

  def calculate!
    log_loss_sum = completed_test_data.inject(0.0) do |log_loss, test_datum|
      log_loss + if test_datum.ground_truth == RESULT_UP
                   Math.log(test_datum.up_probability)
                 else
                   Math.log(test_datum.down_probability)
                 end
    end
    update!(log_loss: -log_loss_sum / completed_test_data.size)
    broadcast(log_loss: log_loss)
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

  def broadcast(updated_attribute = {})
    updated_attribute.merge!(slice(:evaluation_id, :state))
    ActionCable.server.broadcast('evaluation', updated_attribute)
  end

  def completed_test_data
    test_data.select do |test_datum|
      test_datum.up_probability and test_datum.down_probability
    end
  end
end
