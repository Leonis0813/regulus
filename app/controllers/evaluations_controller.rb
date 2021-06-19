class EvaluationsController < ApplicationController
  include ModelUtil

  before_action :check_request_evaluation, only: %i[show]

  def index
    @evaluation = Evaluation.new
    @evaluations = Evaluation.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_params(%i[model from to], execute_params)

    model = execute_params[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    evaluation = Evaluation.new(
      model: model.original_filename,
      from: execute_params[:from],
      to: execute_params[:to],
    )

    unless evaluation.save
      error_codes = evaluation.errors.messages.keys.sort.map do |key|
        "invalid_param_#{key}"
      end
      raise BadRequest, error_codes
    end

    output_dir = Rails.root.join(Settings.evaluation.base_model_dir, evaluation.id.to_s)
    output_model(output_dir, model)

    EvaluationJob.perform_later(evaluation)
    render status: :ok, json: {}
  end

  def show; end

  private

  def check_request_evaluation
    raise NotFound unless evaluation
  end

  def evaluation
    @evaluation ||= Evaluation.includes(:test_data)
                              .find_by(request.path_parameters.slice(:evaluation_id))
  end

  def execute_params
    @execute_params ||= request.request_parameters.slice(:model, :from, :to)
  end
end
