# coding: utf-8

module PredictionHelper
  def icon_class(prediction)
    case prediction.state
    when 'processing'
      'glyphicon-question-sign glyphicon-black'
    when 'error'
      'glyphicon-remove glyphicon-red'
    when 'completed'
      icon_class_by_result(prediction.result)
    end
  end

  def means_to_display(means)
    case means
    when 'manual'
      '手動'
    when 'auto'
      '自動'
    end
  end

  def pairs
    Settings.pairs
  end

  def config_to_display(configs, pair)
    target_config = configs.find {|config| config['pair'] == pair }
    {
      'color' => color_by_config(target_config),
      'status' => status_by_config(target_config),
    }
  end

  private

  def icon_class_by_result(result)
    case result
    when 'up'
      'glyphicon-circle-arrow-up glyphicon-blue'
    when 'down'
      'glyphicon-circle-arrow-down glyphicon-red'
    when 'range'
      'glyphicon-circle-arrow-right glyphicon-orange'
    end
  end

  def color_by_config(config)
    if config and config['status'] == 'active'
      'success'
    else
      'danger'
    end
  end

  def status_by_config(config)
    if config and config['status'] == 'active'
      '有効'
    else
      '無効'
    end
  end
end
