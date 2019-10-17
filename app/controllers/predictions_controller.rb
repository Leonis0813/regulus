class PredictionsController < ApplicationController
  include ModelUtil

  def manage
    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(params[:page])
  end

  def execute
    check_absent_params(%i[model], execute_params)

    model = attributes[:model]
    raise BadRequest, 'invalid_param_model' unless model.respond_to?(:original_filename)

    prediction = Prediction.new(
      attributes.merge(
        prediction_id: SecureRandom.hex,
        model: model.original_filename,
        means: Prediction::MEANS_MANUAL,
        state: Prediction::STATE_PROCESSING,
      ),
    )

    unless prediction.save
      error_codes = prediction.errors.messages.keys.map {|key| "invalid_param_#{key}" }
      raise BadRequest, error_codes
    end

    output_dir = Rails.root.join(Settings.prediction.base_model_dir, prediction.id.to_s)
    output_model(output_dir, model)

    PredictionJob.perform_later(prediction.id, output_dir.to_s)
    render status: :ok, json: {}
  end

  def settings
    check_absent_params(%i[auto], request.request_parameters)

    auto = request.request_parameters[:auto]
    check_absent_params(%i[status], auto)

    status = auto[:status]
    raise BadRequest, 'invalid_param_status' unless %w[active inactive].include?(status)

    file_path = Rails.root.join(Settings.prediction.auto.config_file)
    configs = []
    configs = YAML.load_file(file_path) if File.exists?(file_path)
    configs.map!(&:deep_stringify_keys)
    new_config = {'status' => status}

    if status == 'active'
      check_absent_params(%i[model], auto)

      model = auto[:model]
      raise BadRequest, 'invalid_param_model' unless valid_model?(model)

      auto_dir = Rails.root.join(
        Settings.prediction.base_model_dir,
        Settings.prediction.auto.model_dir,
      )
      tmp_dir = File.join(auto_dir, 'tmp')
      output_model(tmp_dir, model)
      unzip_model(File.join(tmp_dir, model.original_filename), tmp_dir)

      pair = YAML.load_file(File.join(tmp_dir, 'metadata.yml'))['pair']
      pair_dir = File.join(auto_dir, pair)
      FileUtils.rm_rf(pair_dir) if File.exists?(pair_dir)
      FileUtils.mv(tmp_dir, pair_dir)

      configs.reject! {|config| config['pair'] == pair }
      new_config.merge!('filename' => model.original_filename, 'pair' => pair)
    else
      check_absent_params(%i[pair], auto)
      configs.reject! {|config| config['pair'] == auto[:pair] }
      new_config['pair'] = auto[:pair]
    end

    File.open(file_path, 'w') {|file| YAML.dump(configs.push(new_config), file) }

    @prediction = Prediction.new
    @predictions = Prediction.all.order(created_at: :desc).page(1)
    render action: :manage
  end

  private

  def execute_params
    request.request_parameters.permit(:model)
  end
end
