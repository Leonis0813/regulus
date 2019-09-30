# coding: utf-8

module PredictionHelper
  module_function

  def response_keys
    @response_keys ||= %w[prediction_id model from to pair means result state created_at]
  end
end
