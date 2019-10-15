# Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#new_prediction').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '予測を開始しました',
      message: '終了後、実行履歴に結果が表示されます',
      callback: ->
        location.reload()
        return
    })
    return

  $('#new_prediction').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  $('#setting').on 'ajax:success', (event, config, status) ->
    if (config.status == 'active')
      message = '<li>' + config.pair + 'の定期予測を開始します</li>' +
        '<li>次の予測から設定したモデルが利用されます</li>'
    else
      message = '<li>' + config.pair + 'の定期予測を停止しました</li>'
    bootbox.alert({
      title: '設定を変更しました',
      message: '<ul>' + message + '</ul>'
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  $('#setting').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return
  return
