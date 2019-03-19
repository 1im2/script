#!/bin/bash

function yumcheckinstall {
    GREPRESULT=`yum list installed | grep $1`
    if [ "${GREPRESULT}" == "" ]; then
        yum install -y $1
    fi
}

yumcheckinstall wget.x86_64
yumcheckinstall vim
yumcheckinstall net-tools
yumcheckinstall libcurl
yumcheckinstall openssl

if [ ! -e ~/.vimrc ] ; then
    echo "set bg=dark" >> ~/.vimrc
    echo "set si" >> ~/.vimrc
    echo "set ci" >> ~/.vimrc
    echo "set ts=4" >> ~/.vimrc
    echo "set sw=4" >> ~/.vimrc

    echo "alias vi=vim" >> ~/.bash_profile
fi

GREPRESULT=`cat /etc/security/limits.conf | grep -v "^#" | grep hard | grep nproc`
if [ "${GREPRESULT}" == "" ] ; then
    echo "* hard nproc 64000" >> /etc/security/limits.conf
    echo "* soft nproc 64000" >> /etc/security/limits.conf
    echo "* hard nofile 64000" >> /etc/security/limits.conf
    echo "* soft nofile 64000" >> /etc/security/limits.conf
fi

MONGOREPO=/etc/yum.repos.d/mongodb-org-4.0.repo
if [ ! -e ${MONGOREPO} ]; then
    echo "[mongodb-org-4.0]" >> ${MONGOREPO}
    echo "name=MongoDB Repository" >> ${MONGOREPO}
    echo "baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.0/x86_64/" >> ${MONGOREPO}
    echo "gpgcheck=1" >> ${MONGOREPO}
    echo "enabled=1" >> ${MONGOREPO}
    echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" >> ${MONGOREPO}

    yum update
fi

GREPRESULT=`yum list installed | grep mongodb-org`
if [ "${GREPRESULT}" == "" ] ; then
    yum install -y mongodb-org
    perl -pi -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
fi

systemctl status mongod
if [ $? -ne 0 ]; then
    systemctl start mongod
fi

#
# mongodb remove
#
# systemctl stop mongod
# yum erase $(rpm -qa | grep mongodb-org)
# sudo rm -r /var/log/mongodb
# sudo rm -r /var/lib/mongo
