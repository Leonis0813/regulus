INSERT IGNORE INTO
  candle_sticks
(
  SELECT
    NULL,
    axis.from,
    axis.to,
    axis.pair,
    axis.interval,
    open.rate AS open,
    close.rate AS close,
    high.rate AS high,
    low.rate AS low
  FROM (
    SELECT DISTINCT
      '$BEGIN' AS 'from',
      '$END' AS 'to',
      pair,
      '$INTERVAL' AS 'interval'
    FROM rates
  ) AS axis
  LEFT JOIN (
    SELECT
      pair,
      bid AS rate
    FROM
      rates
    WHERE
      time = (
        SELECT
          MIN(time)
        FROM
          rates
        WHERE
          time BETWEEN '$BEGIN' AND '$END'
      )
    ORDER BY
      id
    LIMIT
      1
  ) AS open
  ON
    axis.pair = open.pair
  LEFT JOIN (
    SELECT
      pair,
      bid AS rate
    FROM
      rates
    WHERE
      time = (
        SELECT
          MAX(time)
        FROM
          rates
        WHERE
          time BETWEEN '$BEGIN' AND '$END'
      )
    ORDER BY
      id
    LIMIT
      1
  ) AS close
  ON
    axis.pair = close.pair
  LEFT JOIN (
    SELECT
      pair,
      MAX(bid) AS rate
    FROM
      rates
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
      MIN(bid) AS rate
    FROM
      rates
    WHERE
      time BETWEEN '$BEGIN' AND '$END'
    GROUP BY
      pair
  ) AS low
  ON
    axis.pair = low.pair
)
