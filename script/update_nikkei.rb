def create_database(env)
  query = <<"EOF"
CREATE DATABASE IF NOT EXISTS regulus_#{env}
EOF
  `mysql --user=root --password=7QiSlC?4 -e "#{query}"`
end

def create_table(env)
  query = <<"EOF"
CREATE TABLE IF NOT EXISTS
  articles
LIKE
  regulus.articles
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

def insert_values(env)
  query = <<'EOF'
INSERT INTO
  articles
(
  SELECT * FROM regulus.articles
)
ON DUPLICATE KEY UPDATE
  summary = VALUES(summary),
  url = VALUES(url)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

create_database 'development'
create_table 'development'
insert_values 'development'
