#!/bin/sh

set -e

if [ -z "$GEOIPUPDATE_ACCOUNT_ID" ] || [ -z  "$GEOIPUPDATE_LICENSE_KEY" ] || [ -z "$GEOIPUPDATE_EDITION_IDS" ]; then
    echo "ERROR: You must set the environment variables GEOIPUPDATE_ACCOUNT_ID, GEOIPUPDATE_LICENSE_KEY, and GEOIPUPDATE_EDITION_IDS!"
    exit 1
fi


# Create geoipupdate configuration
cat <<EOF > '/etc/GeoIP.conf'
AccountID $GEOIPUPDATE_ACCOUNT_ID
LicenseKey $GEOIPUPDATE_LICENSE_KEY
EditionIDs $GEOIPUPDATE_EDITION_IDS
EOF

# Run geoipupdate and certbot renew for the first time
geoipupdate -d /usr/share/GeoIP -f /etc/GeoIP.conf -v
certbot renew


# Prepare nginx configuration
if [ ! -f "/etc/nginx/nginx.conf" ]; then
    echo "Nginx configuration not found. Copying from template (/root/nginx/)."
    cp -r /root/nginx/config/* /etc/nginx/
    ln -s /usr/lib/nginx/modules /etc/nginx/modules
else
    echo "Using existing /etc/nginx/nginx.conf."
fi

# Prepare nginx content
if [ ! "$(ls -A /usr/share/nginx/html)" ]; then
    echo "Nginx content not found. Copying from template (/root/nginx/content/)."
    cp -R /root/nginx/content/html /usr/share/nginx/html
else
    echo "Using existing /usr/share/nginx/html."
fi



exec "$@"
