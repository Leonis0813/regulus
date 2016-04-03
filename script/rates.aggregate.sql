INSERT INTO
  rates
(
  SELECT
    axis.from_date,
    axis.to_date,
    axis.pair,
    axis.interval,
    open.rate AS open,
    close.rate AS close,
    high.rate AS high,
    low.rate AS low,
    NOW() AS created_at,
    NOW() AS updated_at
  FROM (
    SELECT DISTINCT
      '$BEGIN' AS from_date,
      '$END' AS to_date,
      pair,
      '$INTERVAL' AS 'interval'
    FROM regulus.rates
  ) AS axis
  LEFT JOIN (
    SELECT
      pair,
      rate
    FROM
      regulus.rates
    WHERE
      time = (
        SELECT
          MIN(time)
        FROM
          regulus.rates
        WHERE
          time BETWEEN '$BEGIN' AND '$END'
      )
  ) AS open
  ON
    axis.pair = open.pair
  LEFT JOIN (
    SELECT
      pair,
      rate
    FROM
      regulus.rates
    WHERE
      time = (
        SELECT
          MAX(time)
        FROM
          regulus.rates
        WHERE
          time BETWEEN '$BEGIN' AND '$END'
      )
  ) AS close
  ON
    axis.pair = close.pair
  LEFT JOIN (
    SELECT
      pair,
      MAX(rate) AS rate
    FROM
      regulus.rates
    WHERE
      time BETWEEN '$BEGIN' AND '$END'
    GROUP BY
      pair
  ) AS high
  ON
    axis.pair = high.pair
  LEFT JOIN (
    SELECT
      pair,
      MIN(rate) AS rate
    FROM
      regulus.rates
    WHERE
      time BETWEEN '$BEGIN' AND '$END'
    GROUP BY
      pair
  ) AS low
  ON
    axis.pair = low.pair
)
ON DUPLICATE KEY UPDATE
  open = VALUES(open),
  close = VALUES(close),
  high = VALUES(high),
  low = VALUES(low),
  updated_at = NOW()
