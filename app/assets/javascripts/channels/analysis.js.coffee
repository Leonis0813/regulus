App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  received: (analysis) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}

    trId = "##{analysis.analysis_id}"
    if $(trId).length
      classNames = ['performed_at', 'period', 'pair', 'batch_size', 'state']
      $.each(classNames, (i, className) ->
        column = $("#{trId} > td[class*=#{className}]")
        column.removeClass('warning')
        column.addClass(stateToClassMap[analysis.state])

        if analysis.state == 'processing' and className == 'performed_at'
          column[0].innerText = analysis.performed_at
        if className == 'state'
          column[0].innerText = displayedState[analysis.state]
        return
      )
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
