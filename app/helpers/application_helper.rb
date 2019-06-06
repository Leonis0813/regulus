# coding: utf-8

module ApplicationHelper
  def time_to_string(time)
    time.strftime('%Y/%m/%d %T')
  end

  def period_to_string(from. to)
    "#{time_to_string(from)} 〜 #{time_to_string(to)}"
  end

  def state_to_class(state)
    case state
    when 'completed'
      'success'
    when 'processing'
      'warning'
    when 'error'
      'danger'
    end
  end

  def state_to_title(state)
    case state
    when 'completed'
      '完了'
    when 'processing'
      '実行中'
    when 'error'
      'エラー'
    end
  end
end
