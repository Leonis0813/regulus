update_tweet = ->
  $('#tweet').load('/tweets/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_tweet();
  , 1000);
  update_tweet()
  return
