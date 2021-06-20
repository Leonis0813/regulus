App.evaluation = App.cable.subscriptions.create "Evaluation::TestDatumChannel",
  received: (test_datum) ->
    switch evaluation.message_type
      when 'create'
        @createRow(test_datum)
      when 'update'
        @updateRow(test_datum)
      else
        $('#log-loss').text(logLoss)
    return

  createRow: (test_datum) ->
    $('#evaluation-test-datum').append("""
    <tr id='#{test_datum.id}'>
      <td>#{test_datum.no}</td>
      <td>#{test_datum.from} 〜 #{test_datum.to}</td>
      <td class='prediction-result'></td>
      <td>
        <span class='glyphicon #{@trendIcon(test_datum.ground_truth)}'></span>
      </td>
    </tr>
    """)
    return

  updateRow: (test_datum) ->
    $("##{test_datum.id} > td.prediction-result").append("""
      <span class='glyphicon #{@trendIcon(test_datum.prediction_result)}'></span>
    """)
    return

  trendIcon: (trend) ->
    switch trend
      when 'up'
        'glyphicon-circle-arrow-up glyphicon-blue'
      when 'down'
        'glyphicon-circle-arrow-down glyphicon-red'
