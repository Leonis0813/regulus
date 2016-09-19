require_relative '../config/settings'

def out_of_service?
  now = Time.now
  from, to = Settings.rate['import']['out_of_service']['from'], Settings.rate['import']['out_of_service']['to']

  now.saturday? or
    (now.friday? and now.hour > from['hour']) or
    (now.friday? and now.hour == from['hour'] and now.min > from['minute']) or
    (now.sunday? and now.hour < to['hour']) or
    (now.sunday? and now.hour == to['hour'] and now.min < to['minute'])
end
