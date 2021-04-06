$ ->
  $('.new-analysis').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '分析を開始しました',
      message: '終了後、メールにて結果を通知します',
    })
    $.ajax({
      url: location.href,
      dataType: 'script',
    })
    return

  $('.new-analysis').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  $('#analysis-result').on 'click', ->
    bootbox.dialog({
      title: '<span style="font-size:20px">モデルを選択してください</span>',
      message: '<form id="new-analysis-result">' +
        '<input id="model" class="form-control" type="file">' +
        '</form>',
      buttons: {
        cancel: {
          label: 'キャンセル',
          className: 'btn-default',
          callback: ->
            return
        },
        ok: {
          label: '確認',
          className: 'btn-primary',
          callback: ->
            $('#new-analysis-result').on 'submit', (event) ->
              formData = new FormData()
              file = $('#model')[0].files[0]
              formData.append('model', file)

              $.ajax({
                type: 'PUT',
                url: '/regulus/analyses/result',
                data: formData,
                processData: false,
                contentType: false,
              }).done((data) ->
                link = '<a href="/regulus/tensorboard" target="_blank">こちら</a>'
                bootbox.alert({
                  title: 'モデルを設定しました',
                  message: link + 'から結果を確認できます'
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
            $('#new-analysis-result').submit()
            return
        }
      }
    })
    return
  return
