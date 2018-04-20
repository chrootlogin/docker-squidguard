#!/usr/bin/env bash

set -ex

CONFIG_FILE="/usr/local/squidGuard/squidGuard.conf"
DB_LOCATION="/usr/local/squidGuard/db"
LOG_LOCATION="/logs"

echo "Downloading blocklist..."
wget -q ${BLOCKLIST} -O /tmp/blocklist.tgz

echo "Extracting blocklist..."
mkdir -p /tmp/blocklist
tar xzf /tmp/blocklist.tgz --strip-components=1 -C /tmp/blocklist

echo "Creating config file..."
rm ${CONFIG_FILE}
touch ${CONFIG_FILE}

echo "dbhome ${DB_LOCATION}" >> ${CONFIG_FILE}
echo "logdir ${LOG_LOCATION}" >> ${CONFIG_FILE}

for CATEGORY in $(echo ${BLOCKED_CATEGORIES} | sed "s/,/ /g")
do
  if [ ! -d /tmp/blocklist/${CATEGORY} ]; then
    echo "Category ${CATEGORY} not available!"
    exit 1
  fi

  cp -r /tmp/blocklist/${CATEGORY} ${DB_LOCATION}/

	echo "dest ${CATEGORY} {" >> ${CONFIG_FILE}

	if [ -e "${DB_LOCATION}/${CATEGORY}/domains" ]; then
		    echo "	domainlist ${CATEGORY}/domains" >> ${CONFIG_FILE}
	fi

	if [ -e "${DB_LOCATION}/${CATEGORY}/urls" ]; then
		    echo "	urllist ${CATEGORY}/urls" >> ${CONFIG_FILE}
	fi

	if [ -e "${DB_LOCATION}/${CATEGORY}/expressions" ]; then
		echo "	expressionlist ${CATEGORY}/expressions" >> ${CONFIG_FILE}
	fi

  echo "}" >> ${CONFIG_FILE}
done

NOT_LIST="${BLOCKED_CATEGORIES//,/ !}"

echo "acl {" >> ${CONFIG_FILE}
echo "	default {" >> ${CONFIG_FILE}
echo "		pass !${NOT_LIST} all" >> ${CONFIG_FILE}
echo "		redirect http://exampleblockpage.com" >> ${CONFIG_FILE}
echo "	}" >> ${CONFIG_FILE}
echo "}" >> ${CONFIG_FILE}

squidGuard -C all

chown -R squid:squid ${DB_LOCATION}
chown -R squid:squid ${LOG_LOCATION}
chown -R squid:squid ${CONFIG_FILE}

echo "Cleanup..."
rm -rf /tmp/*
