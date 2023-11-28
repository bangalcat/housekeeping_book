#!/bin/bash
set -e

# This script is for deploying the app to a baremetal server.

# Update to latest version of code
cd $APP_DIR
git fetch
git reset --hard origin/main
mix deps.get --only prod

# CI Steps
echo 'Skipping CI Steps..'
# mix test
# mix credo --strict

export MIX_ENV=prod
echo 'Assets deploy..'
mix assets.deploy
current_release=$(ls ../releases | sort -nr | head -n 1)
now_in_unix_seconds=$(date +'%s')
if [[ $current_release == '' ]]; then
	current_release=$now_in_unix_seconds
fi

echo 'Current Release: ' $current_release

# Create release
mix release --path ../releases/${now_in_unix_seconds}

source ../releases/${current_release}/releases/0.1.0/env.sh

if [[ $DEPLOY_HTTP_PORT == '4000' ]]; then
	http=4001
	https=4041
	old_port=4000
else
	http=4000
	https=4040
	old_port=4001
fi

# Put env vars with the ports to forward to, and set non-conflicting node name
rm ../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
touch ../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
echo "export DEPLOY_HTTP_PORT=${http}" >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
echo "export DEPLOY_HTTPS_PORT=${https}" >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
echo "export RELEASE_NAME=${http}" >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
echo 'export RELEASE_DISTRIBUTION="name"' >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
echo "export RELEASE_NODE=bangl${http}@0.0.0.0" >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh
awk '/^[^#]/ {print "export " $0}' .env >>../releases/${now_in_unix_seconds}/releases/0.1.0/env.sh

# Set the release to the new version
rm ../env_vars || true
touch ../env_vars
echo "RELEASE=${now_in_unix_seconds}" >>../env_vars

# Run migrations
mix ecto.migrate

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
# Just in case the old version was started by systemd after a server
# reboot, also stop the server_reboot version
sudo systemctl stop housekeeping_book@server_reboot
echo 'Deployed!'
