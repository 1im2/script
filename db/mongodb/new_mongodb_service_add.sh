#!/bin/bash

MONGO_NAME=$1
MONGO_PORT=$2
MONGO_DESC=$3
MONGO_RUNNING_OPTION=$4

if [ $# != 4 ]; then
	echo ""
	echo "Usage: $0 (MONGO NAME) (MONGO PORT) (MONGO DESCIPTION with double queto) (MONGO_RUNNING_OPTION with double queto)"
	echo ""
	echo ""
	exit 0
fi

rm -rf /var/lib/${MONGO_NAME} /var/log/${MONGO_NAME} /usr/lib/systemd/system/${MONGO_NAME}.service /etc/systemd/system/multi-user.target.wants/${MONGO_NAME}.service /usr/lib/systemd/system/${MONGO_NAME}.service* /etc/${MONGO_NAME}.conf


mkdir /var/lib/${MONGO_NAME}
chown mongod:mongod /var/lib/${MONGO_NAME}
chcon -R --reference=/var/lib/mongo /var/lib/${MONGO_NAME}

mkdir /var/log/${MONGO_NAME}
chown mongod:mongod /var/log/${MONGO_NAME}
chcon -R --reference=/var/log/mongodb /var/log/${MONGO_NAME}

cp /usr/lib/systemd/system/mongod.service /usr/lib/systemd/system/${MONGO_NAME}.service
chcon --reference=/usr/lib/systemd/system/mongod.service /usr/lib/systemd/system/${MONGO_NAME}.service
cd /etc/systemd/system/multi-user.target.wants
ln -s /usr/lib/systemd/system/${MONGO_NAME}.service

perl -pi.orig -e "s/MongoDB Database Server/${MONGO_DESC}/g" /usr/lib/systemd/system/${MONGO_NAME}.service
perl -pi -e "s/OPTIONS=/OPTIONS=${MONGO_RUNNING_OPTION} /g" /usr/lib/systemd/system/${MONGO_NAME}.service
perl -pi -e "s/mongod.conf/${MONGO_NAME}.conf/g" /usr/lib/systemd/system/${MONGO_NAME}.service
perl -pi -e "s/mongod.pid/${MONGO_NAME}.pid/g" /usr/lib/systemd/system/${MONGO_NAME}.service

chcon --reference=/etc/mongod.conf /etc/${MONGO_NAME}.conf
cp  /etc/mongod.conf /etc/${MONGO_NAME}.conf
perl -pi -e "s/27017/${MONGO_PORT}/g" /etc/${MONGO_NAME}.conf
perl -pi -e "s/mongod.conf/${MONGO_NAME}.conf/g" /etc/${MONGO_NAME}.conf
perl -pi -e "s/\/log\/mongodb\/mongod/\/log\/mongodb\/${MONGO_NAME}/g" /etc/${MONGO_NAME}.conf
perl -pi -e "s/\/run\/mongodb\/mongod/\/run\/mongodb\/${MONGO_NAME}/g" /etc/${MONGO_NAME}.conf
perl -pi -e "s/\/var\/lib\/mongo/\/var\/lib\/${MONGO_NAME}/g" /etc/${MONGO_NAME}.conf
chcon --reference=/etc/mongod.conf /etc/${MONGO_NAME}.conf


yum install policycoreutils-python
semanage port -a -t mongod_port_t -p tcp ${MONGO_PORT}
firewall-cmd --permanent --zone=public --add-port=${MONGO_PORT}/tcp
firewall-cmd --reload

echo "에러 발생시 /var/log/message 파일 및 /var/log/${MONGO_NAME} 디렉터리 아래 로그 확인"
echo "/etc/${MONGO_NAME}.conf 수정 해야함 그리고 다음 명령어 실행"
echo "       # systemctl enable ${MONGO_NAME}"
echo "       # systemctl start ${MONGO_NAME}"
