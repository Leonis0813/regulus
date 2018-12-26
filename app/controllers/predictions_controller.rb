class PredictionsController < ApplicationController
  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(:created_at => :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*prediction_params)
    absent_keys = prediction_params - attributes.symbolize_keys.keys
    raise BadRequest.new(absent_keys.map {|key| "absent_param_#{key}" }) unless absent_keys.empty?

    prediction = Prediction.new(attributes.merge(:state => 'processing'))
    if prediction.save
      PredictionJob.perform_later(prediction.id)
      render :status => :ok, :json => {}
    else
      raise BadRequest.new(analysis.errors.messages.keys.map {|key| "invalid_param_#{key}" })
    end
  end

  private

  def prediction_params
    %i[ model ]
  end
end
