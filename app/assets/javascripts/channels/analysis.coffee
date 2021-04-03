App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  connected: ->
    console.log('connected')
    return

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    console.log(data)
    return
