class AnalysesController < ApplicationController
  include ModelUtil

  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_params(%i[batch_size from pair to], execute_params)

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

  def upload_result
    check_absent_params(%i[model], request.request_parameters)

    model = params[:model]
    raise BadRequest, 'invalid_param_model' unless valid_model?(model)

    dir = Rails.root.join(
      Settings.analysis.base_model_dir,
      Settings.analysis.tensorboard_dir,
    )
    FileUtils.rm_rf(Dir[File.join(dir, '*')])

    output_model(dir, model)
    unzip_model(File.join(dir, model.original_filename), dir)

    render status: :ok, json: {}
  end

  private

  def execute_params
    request.request_parameters.permit(:batch_size, :from, :pair, :to)
  end
end
