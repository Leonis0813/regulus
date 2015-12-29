def create_database(env)
  query = <<"EOF"
CREATE DATABASE IF NOT EXISTS regulus_#{env}
EOF
  `mysql --user=root --password=7QiSlC?4 -e "#{query}"`
end

def create_table(env)
  query = <<"EOF"
CREATE TABLE IF NOT EXISTS
  currencies
LIKE
  regulus_development.currencies
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

def insert_values(env)
  query = <<'EOF'
INSERT INTO
  currencies
(
  SELECT * FROM regulus_development.currencies
)
ON DUPLICATE KEY UPDATE
  open = VALUES(open),
  close = VALUES(close),
  high = VALUES(high),
  low = VALUES(low),
  updated_at = NOW()
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

create_database 'production'
create_table 'production'
insert_values 'production'
