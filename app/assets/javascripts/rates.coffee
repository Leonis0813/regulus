update_rate = ->
  $('#rate').load('/rates/update', 'pair=' + $('#pair').val() + '&interval=' + $('#interval').val());
  return

$(document).ready ->
  setInterval(
    () ->
      update_rate();
  , 10 * 1000);
  update_rate()
  return
