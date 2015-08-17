def create_database(env)
  query = <<"EOF"
CREATE DATABASE IF NOT EXISTS regulus_#{env}
EOF
  `mysql --user=root --password=7QiSlC?4 -e "#{query}"`
end

def create_table(env)
  query = <<"EOF"
CREATE TABLE IF NOT EXISTS
  tweets
LIKE
  regulus.tweets
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

def insert_values(env)
  query = <<'EOF'
INSERT INTO
  tweets
(
  SELECT * FROM regulus.tweets
)
ON DUPLICATE KEY UPDATE
  user_name = VALUES(user_name),
  full_text = VALUES(full_text)
EOF
  `mysql --user=root --password=7QiSlC?4 regulus_#{env} -e "#{query}"`
end

create_database 'development'
create_table 'development'
insert_values 'development'
