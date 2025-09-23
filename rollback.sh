#!/bin/bash
set -e

# Set APP_DIR environment variable or default to /opt/housekeeping_book
APP_DIR=${APP_DIR:-/opt/housekeeping_book}

# Navigate to app directory
cd $APP_DIR

# Find the current release and the second newest release
current_release=$(ls ../releases | sort -nr | head -n 1)
previous_release=$(ls ../releases | sort -nr | tail -n +2 | head -n 1)

# Get the HTTP_PORT variable from the currently running release
source ../releases/${current_release}/releases/0.1.0/env.sh

if [[ $HTTP_PORT == '4000' ]]; then
	http=4001
	https=4041
	old_port=4000
else
	http=4000
	https=4040
	old_port=4001
fi

# Put env vars with the ports to forward to, and set non-conflicting node name
echo "export HTTP_PORT=${http}" >>../releases/${previous_release}/releases/0.1.0/env.sh
echo "export HTTPS_PORT=${https}" >>../releases/${previous_release}/releases/0.1.0/env.sh
echo "export RELEASE_NAME=${http}" >>../releases/${previous_release}/releases/0.1.0/env.sh

# Set the release to the the previous version
rm ../env_vars || true
touch ../env_vars
echo "RELEASE=${previous_release}" >>../env_vars

# Boot the new version of the app
sudo systemctl start housekeeping_book@${http}

# Wait for the new version to boot
until $(curl --output /dev/null --silent --head --fail localhost:${http}); do
	echo 'Waiting for app to boot...'
	sleep 1
done

# Switch forwarding of ports 443 and 80 to the ones the new app is listening on
sudo iptables -t nat -R PREROUTING 1 -p tcp --dport 80 -j REDIRECT --to-port ${http}
sudo iptables -t nat -R PREROUTING 2 -p tcp --dport 443 -j REDIRECT --to-port ${https}

# Stop the old version
sudo systemctl stop housekeeping_book@${old_port}

# Remove the problematic release
rm -rf ../releases/${current_release}

echo 'Rolled back!'
