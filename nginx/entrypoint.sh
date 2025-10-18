#!/bin/sh

# Expand env var and write the config file to Nginx's active config directory
envsubst '${DEFAULT_HOST}' < /etc/nginx/default.conf.template > /etc/nginx/conf.d/default.conf

# Optional: show config contents for debugging
echo "Generated config:"
cat /etc/nginx/conf.d/default.conf

# Start Nginx in the foreground
nginx -g "daemon off;"