$ ->
  $('#new_prediction').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '予測を開始しました',
      message: '終了後、実行履歴に結果が表示されます',
    })
    $.ajax({
      url: location.href,
      dataType: 'script',
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

  $('input[name="auto[status]"]:radio').on 'change', ->
    $('.form-active,.form-inactive').prop('disabled', true)
    $('.form-setting').addClass('not-selected')
    $('.form-' + $(this).val()).prop('disabled', false)
    $('#form-' + $(this).val()).removeClass('not-selected')
    return
  return
