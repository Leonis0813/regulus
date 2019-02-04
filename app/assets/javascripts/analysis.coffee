# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  successDialog = ->
    bootbox.alert({
      title: '分析を開始しました',
      message: '終了後、メールにて結果を通知します',
      callback: ->
        location.reload()
        return
    })
    return

  failureDialog = ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  $('#new_analysis').on 'ajax:success', (event, xhr, status, error) ->
    successDialog()
    return

  $('#new_analysis').on 'ajax:error', (event, xhr, status, error) ->
    failureDialog()
    return

  $('button.rebuild').on 'click', ->
    period = $(@).parent().siblings()[1].innerText
    data = {
      from: period.split(' 〜 ')[0],
      to: period.split(' 〜 ')[1],
      batch_size: parseInt($(@).parent().siblings()[2].innerText),
    }
    $.ajax({
      type: 'POST',
      url: '/regulus/analyses',
      data: data,
    }).done((data) ->
      successDialog()
      return
    ).fail((xhr, status, error) ->
      failureDialog()
      return
    )
    return
