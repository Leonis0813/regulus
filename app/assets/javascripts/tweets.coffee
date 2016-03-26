update_tweet = ->
  $('#tweet').load('/tweet/update');
  return

$(document).ready ->
  setInterval(
    () ->
      update_tweet();
  , 1000);
  update_tweet()
  return
