App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  received: (analysis) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}

    $.each(['performed_at', 'period', 'pair', 'batch_size', 'state'], (i, className) ->
      column = $("##{analysis.analysis_id} > td[class*=#{className}]")
      column.removeClass('warning')
      column.addClass(stateToClassMap[analysis.state])

      if analysis.state == 'processing' and className == 'performed_at'
        column[0].innerText = analysis.performed_at
      if className == 'state'
        column[0].innerText = displayedState[analysis.state]
      return
    )
    return
