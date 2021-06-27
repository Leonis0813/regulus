App.evaluation = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    trId = "##{evaluation.evaluation_id}"

    if $(trId).length
      switch evaluation.state
        when 'processing'
          $(trId).addClass('warning')
          $("#{trId} > td.performed_at").text(evaluation.performed_at)
          $("#{trId} > td.pair").text(evaluation.pair)
          $("#{trId} > td.log_loss").text(evaluation.log_loss)
          $("#{trId} > td.state").text('実行中')
        when 'completed'
          $(trId).removeClass()
          $(trId).addClass('success')
          $("#{trId} > td.state").text('完了')
        when 'error'
          $(trId).removeClass()
          $(trId).addClass('danger')
          $("#{trId} > td.state").text('エラー')
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
