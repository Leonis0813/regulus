update_article = ->
  $('#article').load('/article/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_article();
  , 60 * 1000);
  update_article()
  return
