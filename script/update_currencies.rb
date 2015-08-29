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
  regulus.currencies
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

def insert_values(env)
  query = <<'EOF'
INSERT INTO
  currencies
(
  SELECT * FROM regulus.currencies
)
ON DUPLICATE KEY UPDATE
  rate = VALUES(rate)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

create_database 'development'
create_table 'development'
insert_values 'development'
