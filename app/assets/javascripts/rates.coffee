update_rate = ->
  $('#rate').load('/rates/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_rate();
  , 10 * 1000);
  update_rate()
  return
