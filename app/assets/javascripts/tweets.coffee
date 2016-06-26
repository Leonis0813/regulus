update_tweet = ->
  $('#tweet').load('/tweets/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_tweet();
  , 10 * 1000);
  return

$(document).on 'page:change', ->
  update_tweet()
  return
