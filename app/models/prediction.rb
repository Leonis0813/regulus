class Prediction < ApplicationRecord
  PAIR_LIST = Analysis::PAIR_LIST
  MEANS_MANUAL = 'manual'.freeze
  MEANS_AUTO = 'auto'.freeze
  MEANS_LIST = [MEANS_MANUAL, MEANS_AUTO].freeze
  RESULT_LIST = %w[up down range].freeze

  validate :valid_period?
  validates :prediction_id, :model, :state,
            presence: {message: 'absent'}
  validates :prediction_id,
            format: {with: /\A[0-9a-zA-Z]{32}\z/, message: 'invalid'},
            allow_nil: true
  validates :model,
            format: {with: /\.zip\z/, message: 'invalid'},
            allow_nil: true
  validates :pair,
            inclusion: {in: PAIR_LIST, message: 'invalid'},
            allow_nil: true
  validates :means,
            inclusion: {in: MEANS_LIST, message: 'invalid'},
            allow_nil: true
  validates :result,
            inclusion: {in: RESULT_LIST, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'},
            allow_nil: true

  belongs_to :analysis

  after_initialize if: :new_record? do |prediction|
    prediction.prediction_id = SecureRandom.hex
    prediction.state = DEFAULT_STATE
  end

  private

  def valid_period?
    return unless from and to
    return if from < to

    errors.add(:from, 'invalid')
    errors.add(:to, 'invalid')
  end

  def set_analysis!
    metadata = YAML.load_file(Rails.root.join('scripts/tmp/metadata.yml'))
    analysis = Analysis.find_by(analysis_id: metadata['analysis_id'])
    raise StandardError if analysis.nil?

    update!(analysis: analysis)
  end
end
