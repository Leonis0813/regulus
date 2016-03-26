update_currency = ->
  $('#currency').load('/rate/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_currency();
  , 10 * 1000);
  update_currency()
  return
