SELECT
  cs.from AS time,
  cs.open AS open,
  ma25.value AS ma25,
  ma75.value AS ma75,
  ma200.value AS ma200
FROM
  candle_sticks AS cs
LEFT JOIN
  moving_averages AS ma25
ON
  cs.from = ma25.time AND
  cs.pair = ma25.pair AND
  cs.time_frame = ma25.time_frame
LEFT JOIN
  moving_averages AS ma75
ON
  cs.from = ma75.time AND
  cs.pair = ma75.pair AND
  cs.time_frame = ma75.time_frame
LEFT JOIN
  moving_averages AS ma200
ON
  cs.from = ma200.time AND
  cs.pair = ma200.pair AND
  cs.time_frame = ma200.time_frame
WHERE
  DATE(cs.from) <= "${TO}" AND
  cs.pair = "${PAIR}" AND
  cs.time_frame = "D1" AND
  ma25.period = 25 AND
  ma75.period = 75 AND
  ma200.period = 200
ORDER BY
  cs.from DESC
LIMIT
  20
