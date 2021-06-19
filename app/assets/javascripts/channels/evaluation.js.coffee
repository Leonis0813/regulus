App.evaluation = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    trId = "##{evaluation.evaluation_id}"

    if $(trId).length
      switch evaluation.state
        when 'processing'
          $(trId).addClass('warning')
        when 'completed'
          $(trId).removeClass()
          $(trId).addClass('success')
        when 'error'
          $(trId).removeClass()
          $(trId).addClass('danger')
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
