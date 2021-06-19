module EvaluationHelper
  def prediction_result(up, down)
    return if up.nil? or down.nil?

    up > down ? 'up' : 'down'
  end
end
