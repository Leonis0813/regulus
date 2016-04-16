update_tweet = ->
  $('#tweet').load('/tweets/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_tweet();
  , 10 * 1000);
  update_tweet()
  return
