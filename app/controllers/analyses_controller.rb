class AnalysesController < ApplicationController
  def manage
    @analysis = Analysis.new
    @analyses = Analysis.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    attributes = params.permit(*analysis_params)

    absent_keys = analysis_params - attributes.keys.map(&:to_sym)
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

  def upload_result
    raise BadRequest, 'absent_param_model' unless params[:model]

    model = params[:model]
    dir = Rails.root.join(Settings.prediction.base_model_dir, 'tensorboard')
    FileUtils.rm_rf(Dir[File.join(dir, '*')])

    zip_file = File.join(dir, model.original_filename)
    File.open(zip_file, 'w+b') {|file| file.write(model.read) }

    Zip::File.open(zip_file) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(dir, entry.name))
      end
    end

    render status: :ok, json: {}
  end

  private

  def analysis_params
    %i[batch_size from pair to]
  end
end
