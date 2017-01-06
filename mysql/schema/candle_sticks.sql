CREATE TABLE IF NOT EXISTS candle_sticks (
  id INTEGER PRIMARY KEY,
  from DATETIME,
  to DATETIME,
  pair VARCHAR(6),
  open FLOAT,
  close FLOAT,
  high FLOAT,
  low FLOAT,
  UNIQUE(from, to, pair)
)
