update_article = ->
  $('#article').load('/articles/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_article();
  , 60 * 1000);
  return

$(document).on 'page:change', ->
  update_article()
  return
