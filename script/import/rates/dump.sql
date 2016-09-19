SELECT
  *
FROM
  rates
WHERE
  time BETWEEN '$FROM' AND '$TO'
ORDER BY
  time
