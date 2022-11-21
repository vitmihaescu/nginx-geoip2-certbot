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


exec "$@"
