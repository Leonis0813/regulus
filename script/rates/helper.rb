def out_of_service?
  now = Time.now
  from, to = IMPORT['out_of_service']['from'], IMPORT['out_of_service']['to']

  now.saturday? or
    (now.friday? and now.hour > from['hour'] and now.min > from['minute']) or
    (now.sunday? and now.hour < to['hour'] and now.min < to['minute'])
end
