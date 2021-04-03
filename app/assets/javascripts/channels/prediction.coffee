App.prediction = App.cable.subscriptions.create "PredictionChannel",
  received: (prediction) ->
    trId = "##{prediction.prediction_id}"

    switch prediction.state
      when 'processing'
        $(trId).addClass('warning')
        $("#{trId} > td.performed_at")[0].innerText = prediction.performed_at
        changeResultColumn(trId, prediction.state)
      when 'completed'
        row = $(trId)
        row.removeClass()
        row.addClass('success')
      when 'error'
        row = $(trId)
        row.removeClass()
        row.addClass('danger')
        changeResultColumn(trId, prediction.state)
      else
        if prediction.pair
          $("##{prediction.prediction_id} > td.pair")[0].innerText = prediction.pair
        else if prediction.result
          changeResultColumn(trId, 'completed', prediction.result)
    return

  changeResultColumn: (trId, state, result = null) ->
    column = $("#{trId} > td.result")
    switch state
      when 'processing'
        column.addClass('glyphicon-question-sign glyphicon-black')
      when 'error'
        column.removeClass('glyphicon-question-sign glyphicon-black')
        column.addClass('glyphicon-remove glyphicon-red')
      when 'completed'
        column.removeClass('glyphicon-question-sign glyphicon-black')

        switch result
          when 'up'
            column.addClass('glyphicon-circle-arrow-up glyphicon-blue')
          when 'down'
            column.addClass('glyphicon-circle-arrow-down glyphicon-red')
          when 'range'
            column.addClass('glyphicon-circle-arrow-right glyphicon-orange')
    return
