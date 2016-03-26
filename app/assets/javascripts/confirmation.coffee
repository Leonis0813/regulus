update_currency = ->
  $('#currency').load('/rate/update');
  return

update_article = ->
  $('#article').load('/article/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_currency();
  , 10 * 1000);
  setInterval(
    () ->
      update_article();
  , 60 * 1000);
  update_currency()
  update_article()
  return
