class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*analysis_params)
    absent_keys = analysis_params - attributes.symbolize_keys.keys
    unless absent_keys.empty?
      error_codes = absent_keys.sort.map {|key| "absent_param_#{key}" }
      raise BadRequest, error_codes
    end

    analysis = Analysis.new(attributes.merge(state: Analysis::STATE_PROCESSING))
    unless analysis.save
      error_codes = analysis.errors.messages.keys.sort.map do |key|
        "invalid_param_#{key}"
      end
      raise BadRequest, error_codes
    end

    AnalysisJob.perform_later(analysis.id)
    render status: :ok, json: {}
  end

  private

  def analysis_params
    %i[batch_size from pair to]
  end
end
