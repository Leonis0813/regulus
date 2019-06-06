module PredictionHelper
  def icon_class(prediction)
    case prediction.state
    when 'processing'
      'glyphicon-question-sign'
    when 'error'
      'glyphicon-remove'
    when 'completed'
      case prediction.result
      when 'up'
        'glyphicon-circle-arrow-up'
      when 'down'
        'glyphicon-circle-arrow-down'
      when 'range'
        'glyphicon-circle-arrow-right'
      end
    end
  end

  def icon_color(prediction)
    case prediction.state
    when 'processing'
      'black'
    when 'error'
      'red'
    when 'completed'
      case prediction.result
      when 'up'
        'blue'
      when 'down'
        'red'
      when 'range'
        'orange'
      end
    end
  end
end
