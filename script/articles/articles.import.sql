INSERT INTO
  articles
VALUES (
  DATE_FORMAT('$PUBLISHED', '%Y-%m-%d %H:%i:%S'), "$TITLE", "$SUMMARY", '$URL', '$CREATED_AT'
)
ON DUPLICATE KEY UPDATE
  summary = VALUES(summary),
  url = VALUES(url)
