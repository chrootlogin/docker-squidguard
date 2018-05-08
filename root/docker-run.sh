#!/usr/bin/env bash

# Create cache /cache
if [ ! -d /cache ]; then
  mkdir -p /cache
fi

# Create logs directory /logs
if [ ! -d /logs ]; then
  mkdir -p /logs
fi

chown -R squid:squid /cache
chown -R squid:squid /logs

sed -i "s#http://exampleblockpage.com#${REDIRECT_URL}#g" /usr/local/squidGuard/squidGuard.conf

if [ ! -d /cache/00 ]; then
  echo "Initializing cache..."
  /usr/sbin/squid -N -f /etc/squid/squid.conf -z
fi

echo "Starting squid..."
exec /usr/sbin/squid -f /etc/squid/squid.conf -NYCd 1
