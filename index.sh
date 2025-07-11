#!/bin/bash

# Set variables
OLD_DOMAIN1="ican.com"
NEW_DOMAIN1="ican.net"
OLD_DOMAIN2="ucan.com"
NEW_DOMAIN2="ucan.net"
WEBROOT="/var/www/vhosts"
APACHE_CONF="/etc/apache2/sites-available"
BIND_ZONE="/etc/bind"

echo "🚀 Starting domain rename process..."

# Rename web directories
echo "📦 Renaming web directories..."
mv "$WEBROOT/$OLD_DOMAIN1" "$WEBROOT/$NEW_DOMAIN1"
mv "$WEBROOT/$OLD_DOMAIN2" "$WEBROOT/$NEW_DOMAIN2"

# Rename Apache config files
echo "📦 Renaming Apache virtualhost configs..."
mv "$APACHE_CONF/$OLD_DOMAIN1.conf" "$APACHE_CONF/$NEW_DOMAIN1.conf"
mv "$APACHE_CONF/$OLD_DOMAIN2.conf" "$APACHE_CONF/$NEW_DOMAIN2.conf"

# Replace domain names inside Apache configs
echo "📝 Updating Apache config content..."
sed -i "s/$OLD_DOMAIN1/$NEW_DOMAIN1/g" "$APACHE_CONF/$NEW_DOMAIN1.conf"
sed -i "s/$OLD_DOMAIN2/$NEW_DOMAIN2/g" "$APACHE_CONF/$NEW_DOMAIN2.conf"

# Disable old sites and enable new ones
echo "📑 Switching Apache sites..."
a2dissite "$OLD_DOMAIN1.conf"
a2dissite "$OLD_DOMAIN2.conf"
a2ensite "$NEW_DOMAIN1.conf"
a2ensite "$NEW_DOMAIN2.conf"

# Rename DNS zone files
echo "📦 Renaming DNS zone files..."
mv "$BIND_ZONE/db.$OLD_DOMAIN1" "$BIND_ZONE/db.$NEW_DOMAIN1"
mv "$BIND_ZONE/db.$OLD_DOMAIN2" "$BIND_ZONE/db.$NEW_DOMAIN2"

# Replace domain names inside DNS zone files
echo "📝 Updating DNS zone file content..."
sed -i "s/$OLD_DOMAIN1/$NEW_DOMAIN1/g" "$BIND_ZONE/db.$NEW_DOMAIN1"
sed -i "s/$OLD_DOMAIN2/$NEW_DOMAIN2/g" "$BIND_ZONE/db.$NEW_DOMAIN2"

# Update Bind config named.conf.local
echo "📝 Updating named.conf.local..."
sed -i "s/$OLD_DOMAIN1/$NEW_DOMAIN1/g" "$BIND_ZONE/named.conf.local"
sed -i "s/$OLD_DOMAIN2/$NEW_DOMAIN2/g" "$BIND_ZONE/named.conf.local"

# Restart services
echo "🔄 Restarting Apache, BIND9, vsftpd..."
systemctl reload apache2
systemctl restart bind9
systemctl restart vsftpd
ufw reload

echo "✅ Done! All domains renamed to $NEW_DOMAIN1 and $NEW_DOMAIN2."

