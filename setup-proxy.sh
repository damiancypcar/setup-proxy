#!/usr/bin/env bash
# ----------------------------------------------------------
# Author:          damiancypcar
# Modified:        10.03.2023
# Version:         2.0
# Desc:            Setup the proxy server
# inspired by Michael Wahler work
# ----------------------------------------------------------

set -euo pipefail

PROXYURL="<proxy address>"
BAKDIR="$HOME/.proxy_bak"

# shellcheck disable=SC2046
if [ $(id -u) -ne 0 ]; then
    echo "You must be ROOT to run this script"
    exit 1
fi

echo "This script sets up proxy in the Ubuntu/Debian environment"
echo "Backups of configuration files will be made to $HOME/.proxy_bak/"
echo

read -rp "Press any key to continue or Ctrl-C to exit..." -n1 -s

echo -e "\n"
echo "Starting..."

# create backup directory, -p eliminates warning if directory exists
mkdir -p "$BAKDIR"

echo "Adding proxy to apt"
cp -v /etc/apt/apt.conf "$BAKDIR/apt.conf" || echo "Nothing to back up"
APTCONF=/etc/apt/apt.conf
cat << EOF >> $APTCONF
"Acquire::http::Proxy \"$PROXYURL\";"
"Acquire::https::Proxy \"$PROXYURL\";"
EOF

echo 'Adding script to set proxy to /etc/profile.d'
PSCRIPT=/etc/profile.d/proxies.sh
cat << EOF > $PSCRIPT
#!/usr/bin/env bash
export http_proxy="$PROXYURL"
export https_proxy="$PROXYURL"
export no_proxy="localhost,127.0.0.1"
EOF

chmod +x $PSCRIPT

echo "Updating the package directory"
apt-get update

# echo "Installing bonjour for broadcasting this device's hostname"
# apt-get install libnss-mdns libnss-winbind winbind
