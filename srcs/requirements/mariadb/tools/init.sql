DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
GRANT ALL PRIVILEGES on wordpress.* TO 'wp_root'@'%' IDENTIFIED BY 'wp_root_pass';
GRANT ALL PRIVILEGES on wordpress.* TO 'wp_user'@'%' IDENTIFIED BY 'wp_user_pass';
FLUSH PRIVILEGES;
