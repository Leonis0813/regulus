update_rate = ->
  $('#rate').load('/rates/update', 'pair=' + $('#pair').val() + '&interval=' + $('#interval').val());
  return

$(document).ready ->
  setInterval(
    () ->
      update_rate();
  , 10 * 1000);
  return

$(document).on 'page:change', ->
  update_rate()
  return
