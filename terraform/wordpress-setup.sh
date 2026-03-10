#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Install PHP 8.2 and required extensions
amazon-linux-extras install -y php8.2
yum install -y \
    php-cli \
    php-fpm \
    php-mysql \
    php-json \
    php-gd \
    php-mbstring \
    php-xml \
    php-curl

# Install MySQL 8.0
yum install -y mysql80-server

# Create necessary directories
mkdir -p /var/www/html
chown -R apache:apache /var/www/html

# Start services
systemctl start mysqld
systemctl start httpd
systemctl enable mysqld
systemctl enable httpd

# Set MySQL root password and secure installation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';"
mysql -u root -p"${mysql_root_password}" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"${mysql_root_password}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p"${mysql_root_password}" -e "DROP DATABASE IF EXISTS test;"

# Create WordPress database and user
mysql -u root -p"${mysql_root_password}" -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"${mysql_root_password}" -e "CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY '${wordpress_db_password}'; FLUSH PRIVILEGES;"
mysql -u root -p"${mysql_root_password}" -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost'; FLUSH PRIVILEGES;"

# Download WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* /var/www/html/
chown -R apache:apache /var/www/html

# Setup WordPress config
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Generate WordPress salt keys
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Update wp-config.php with database credentials
sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wordpress' );/" wp-config.php
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wordpress' );/" wp-config.php
sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${wordpress_db_password}' );/" wp-config.php
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'localhost' );/" wp-config.php

# Replace salt keys
sed -i "/define( 'AUTH_KEY'/,/define( 'NONCE_SALT'/d" wp-config.php
echo "$SALT" >> wp-config.php

# Fix permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/wp-content

# Create Apache configuration
cat > /etc/httpd/conf.d/wordpress.conf <<'EOF'
<Directory /var/www/html>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF

# Enable mod_rewrite
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Restart Apache
systemctl restart httpd

# Optional: Setup self-signed SSL certificate for HTTPS
if [ "${enable_https}" = "yes" ]; then
    yum install -y mod_ssl openssl
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/pki/tls/private/wordpress.key \
        -out /etc/pki/tls/certs/wordpress.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=example.com"
    
    # Create HTTPS virtual host
    cat > /etc/httpd/conf.d/wordpress-ssl.conf <<'EOFSSL'
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/wordpress.crt
    SSLCertificateKeyFile /etc/pki/tls/private/wordpress.key
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOFSSL
    
    # Redirect HTTP to HTTPS
    sed -i '/<Directory \/var\/www\/html>/a\    RewriteEngine On\n    RewriteCond %{HTTPS} off\n    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]' /etc/httpd/conf.d/wordpress.conf
    
    systemctl restart httpd
fi

# Complete WordPress installation via WP-CLI (if available) or show manual steps
if command -v wp &> /dev/null; then
    wp core install \
        --url="http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" \
        --title="${site_name}" \
        --admin_user="${wordpress_admin_user}" \
        --admin_password="${wordpress_admin_password}" \
        --admin_email="${wordpress_admin_email}" \
        --allow-root
else
    # WordPress will show setup wizard on first visit
    echo "WordPress setup will complete on first browser visit"
fi

# Cleanup
rm -f /tmp/latest.tar.gz
rm -rf /tmp/wordpress

echo "WordPress installation complete!"
