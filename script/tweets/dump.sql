SELECT
  *
FROM
  tweets
WHERE
  created_at BETWEEN '$FROM' AND '$TO'
ORDER BY
  created_at
