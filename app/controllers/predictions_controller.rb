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
    raise BadRequest, ['invalid_param_model'] unless model.respond_to?(:original_filename)

    attributes[:model] = model.original_filename

    prediction = Prediction.new(attributes.merge(state: 'processing'))
    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    output_dir = Rails.root.join('tmp', 'models', prediction.id.to_s)
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir, prediction.model), 'w+b') do |file|
      file.write(model.read)
    end
    PredictionJob.perform_later(prediction.id)
    render status: :ok, json: {}
  end

  private

  def prediction_params
    %i[model]
  end
end
