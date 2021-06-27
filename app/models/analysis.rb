class Analysis < ApplicationRecord
  DEFAULT_PAIR = 'USDJPY'.freeze
  PAIR_LIST = %w[AUDJPY CADJPY CHFJPY EURJPY EURUSD GBPJPY NZDJPY USDJPY].freeze

  validate :valid_period?
  validates :analysis_id, :batch_size, :pair, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :analysis_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :pair,
            inclusion: {in: PAIR_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :batch_size,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true
  validates :min, :max,
            numericality: {greater_than: 0, message: MESSAGE_INVALID},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  has_many :predictions, dependent: :destroy
  has_many :evaluations, dependent: :destroy

  after_initialize if: :new_record? do |analysis|
    analysis.analysis_id = SecureRandom.hex
    analysis.state = DEFAULT_STATE
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    broadcast
  end

  def completed!
    update!(state: STATE_COMPLETED)
    broadcast
  end

  def failed!
    update!(state: STATE_ERROR)
    broadcast
  end

  private

  def broadcast
    updated_attribute = attributes.slice('analysis_id', 'state')
    updated_attribute['performed_at'] = performed_at.strftime('%Y/%m/%d %T')
    ActionCable.server.broadcast('analysis', updated_attribute)
  end

  def valid_period?
    errors.add(:from, 'invalid') unless from
    errors.add(:to, 'invalid') unless to

    return if errors.messages.include?(:from) or errors.messages.include?(:to)
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end
end
