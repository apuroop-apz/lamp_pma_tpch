#!/bin/bash

set -e

function exportBoolean {
    if [ "${!1}" = "**Boolean**" ]; then
            export ${1}=''
    else
            export ${1}='Yes.'
    fi
}

exportBoolean LOG_STDOUT
exportBoolean LOG_STDERR

if [ $LOG_STDERR ]; then
    /bin/ln -sf /dev/stderr /var/log/apache2/error.log
else
        LOG_STDERR='No.'
fi

if [ $ALLOW_OVERRIDE=='All' ]; then
    /bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf
fi

sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini
sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php/7.0/apache2/php.ini

echo "ServerName localhost" >> /etc/apache2/apache2.conf

sed -i "77s@.*@\/\/$cfg['Servers\'][\$i]['controluser'] = \$dbuser;@" /etc/phpmyadmin/config.inc.php
sed -i "78s@.*@\/\/$cfg['Servers\'][\$i]['controlpass'] = \$dbpass;@" /etc/phpmyadmin/config.inc.php

usermod -d /var/lib/mysql/ mysql

make -C /etc/tpch/dbgen/
cd /etc/tpch/dbgen/ && ./dbgen -vf -T s -s 0.1 && ./dbgen -vf -T c -s 0.1 && ./dbgen -vf -T o -s 0.1 && ./dbgen -vf -T p -s 0.1 && ./dbgen -vf -T n -s 0.1 && ./dbgen -vf -T r -s 0.1

service mysql start
mysql -u root -p12345 -e "create database tpch"
mysql -u root -p12345 tpch < /mysql/tpch_test.sql

mysql -u root -p12345 < /usr/share/doc/phpmyadmin/examples/create_tables.sql
mysql -u root -p12345 -e 'GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY "pmapassword"'
service mysql stop

cd /
#Starting Apache & mysql:
service apache2 start && service mysql start &&  bash

