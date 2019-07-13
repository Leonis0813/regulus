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

  $('#btn-prediction-setting').on 'click', ->
    bootbox.dialog({
      title: '<span style="font-size:20px">定期予測で利用するモデルを設定してください</span>',
      message: '<form id="prediction-settings">' +
        '<input id="auto-model" class="form-control" type="file">' +
        '</form>',
      buttons: {
        cancel: {
          label: 'キャンセル',
          className: 'btn-default',
          callback: ->
            return
        },
        ok: {
          label: '保存',
          className: 'btn-primary',
          callback: ->
            $('#prediction-settings').on 'submit', (event) ->
              formData = new FormData()
              formData.append('auto[model]', $('#auto-model')[0].files[0])

              $.ajax({
                type: 'POST',
                url: '/regulus/predictions/settings',
                data: formData,
                processData: false,
                contentType: false,
              }).done((data) ->
                bootbox.alert({
                  title: 'モデルを設定しました',
                  message: '次の予測から設定したモデルが利用されます'
                })
                return
              ).fail((xhr, status, error) ->
                bootbox.alert({
                  title: 'モデルの設定に失敗しました',
                  message: '入力したモデルを見直すか、しばらく待ってから再設定してください'
                })
                return
              )
              return false
            $('#prediction-settings').submit()
            return
        }
      }
    })
    return
  return
