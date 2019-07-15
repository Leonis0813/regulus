class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    unless absent_keys.empty?
      error_codes = absent_keys.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes
    end

    model = attributes[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    attributes.merge!(
      model: model.original_filename,
      means: Prediction::MEANS_MANUAL,
      state: Prediction::STATE_PROCESSING,
    )

    prediction = Prediction.new(attributes)
    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    output_dir = Rails.root.join(config.base_model_dir, prediction.id.to_s)
    output_model(output_dir, model)

    PredictionJob.perform_later(prediction.id, output_dir.to_s)
    render status: :ok, json: {}
  end

  def settings
    raise BadRequest, 'absent_param_auto' unless params[:auto] and params[:auto][:status]

    status = params[:auto][:status]
    raise BadRequest, 'invalid_param_auto' unless %w[active inactive].include?(status)

    setting_file = File.open(Rails.root.join(config.auto.setting_file), 'w')
    setting = {'status' => status}

    if status == 'active'
      model = params[:auto][:model]
      raise BadRequest, 'invalid_param_auto' unless valid_model?(model)

      output_model(Rails.root.join(config.base_model_dir, config.auto.model_dir), model)
      setting['filename'] = model.original_filename
    end

    YAML.dump(setting, setting_file)
    setting_file.close

    render status: :ok, json: {}
  end

  private

  def output_model(dir, model)
    FileUtils.mkdir_p(dir)
    File.open(File.join(dir, model.original_filename), 'w+b') do |file|
      file.write(model.read)
    end
  end

  def prediction_params
    %i[model]
  end

  def config
    @config ||= Settings.prediction
  end

  def valid_model?(model)
    model&.respond_to?(:original_filename) and model.original_filename.end_with?('.zip')
  end
end
