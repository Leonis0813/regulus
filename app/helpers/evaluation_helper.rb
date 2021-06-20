module EvaluationHelper
  def test_datum_row_id(test_datum)
    "#{test_datum.from.strftime('%Y%m%d')-#{test_datum.to.strftime('%Y%m%d')}"
  end

  def test_datum_row_class(test_datum)
    result = prediction_result(test_datum)
    return unless result

    result == test_datum.ground_truth ? 'success' : 'danger'
  end

  def prediction_result(test_datum)
    return if test_datum.up_probability.nil? or test_datum.down_probability.nil?

    test_datum.up_probability > test_datum.down_probability ? 'up' : 'down'
  end

  def trend_icon(trend)
    case trend
    when 'up'
      tag('span', class: 'glyphicon glyphicon-circle-arrow-up glyphicon-blue')
    when 'down'
      tag('span', class: 'glyphicon glyphicon-circle-arrow-down glyphicon-red')
    end
  end
end
