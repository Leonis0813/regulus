# coding: utf-8

module PredictionHelper
  def icon_class(prediction)
    case prediction.state
    when 'processing'
      'glyphicon-question-sign'
    when 'error'
      'glyphicon-remove'
    when 'completed'
      icon_class_by_result(prediction.result)
    end
  end

  def icon_color(prediction)
    case prediction.state
    when 'processing'
      'black'
    when 'error'
      'red'
    when 'completed'
      icon_color_by_result(prediction.result)
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

  def config_to_display(pair)
    target_config = @configs.find {|config| config['pair'] == pair }
    {
      'color' => color_by_config(target_config),
      'status' => status_by_config(target_config),
    }
  end

  private

  def icon_class_by_result(result)
    case result
    when 'up'
      'glyphicon-circle-arrow-up'
    when 'down'
      'glyphicon-circle-arrow-down'
    when 'range'
      'glyphicon-circle-arrow-right'
    end
  end

  def icon_color_by_result(result)
    case result
    when 'up'
      'blue'
    when 'down'
      'red'
    when 'range'
      'orange'
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
