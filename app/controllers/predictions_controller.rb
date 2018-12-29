class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(:created_at => :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    model = attributes[:model]
    if model.respond_to?(:original_filename)
      attributes[:model] = model.original_filename
    else
      raise BadRequest.new(['invalid_param_model'])
    end

    prediction = Prediction.new(attributes.merge(:state => 'processing'))
    if prediction.save
      output_dir = File.join(Rails.root, "tmp/models/#{prediction.id}")
      FileUtils.mkdir_p(output_dir)
      File.open(File.join(output_dir, prediction.model), 'w+b') do |file|
        file.write(model.read)
      end
      PredictionJob.perform_later(prediction.id)
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def prediction_params
    %i[ model ]
  end
end
