#!/bin/bash

# mongodb 4.0.6 base
function func_usage {
	echo ""
	echo "Usage: $0 (MONGO NAME) (MONGO PORT)"
	echo ""
	echo ""
}

if [ $# != 2 ]; then
	func_usage
	exit 0
fi

if [ "$MONGO_NAME" == "" ]; then
	func_usage
	exit 0
fi

MONGO_NAME=$1
MONGO_PORT=$2

rm -rf /var/lib/${MONGO_NAME} /var/log/${MONGO_NAME} /usr/lib/systemd/system/${MONGO_NAME}.service /etc/systemd/system/multi-user.target.wants/${MONGO_NAME}.service /usr/lib/systemd/system/${MONGO_NAME}.service* /etc/${MONGO_NAME}.conf

semanage port --delete -t mongod_port_t -p tcp ${MONGO_PORT}
firewall-cmd --permanent --zone=public --remove-port=${MONGO_PORT}/tcp
