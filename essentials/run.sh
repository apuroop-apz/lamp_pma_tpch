#!/bin/bash

set -e

USER=${MYSQL_USERNAME:-}
PASS=${MYSQL_PASSWORD:-}
DB=${MYSQL_DBNAME:-}
ROOTPASS=${MYSQL_ROOT_PASSWORD:-}

sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/apache2.conf

sed -i "s/short_open_tag\ \=\ Off/short_open_tag\ \=\ On/g" /etc/php/7.0/apache2/php.ini

echo "ServerName localhost" >> /etc/apache2/apache2.conf

sed -i "77s@.*@\/\/$cfg['Servers\'][\$i]['controluser'] = \$dbuser;@" /etc/phpmyadmin/config.inc.php
sed -i "78s@.*@\/\/$cfg['Servers\'][\$i]['controlpass'] = \$dbpass;@" /etc/phpmyadmin/config.inc.php

make -C /etc/tpch/dbgen/
cd /etc/tpch/dbgen/ && ./dbgen -v -s 0.1

/usr/bin/mysqld_safe &
while ! nc -vz localhost 3306; do sleep 1; done

if [ ! -z $USER ]; then
	echo "Creating user: \"$USER\""
		source /essentials/load.sh
		start_spinner
		sleep 2

		/usr/bin/mysql -uroot -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PASS'"
		/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION"
		/usr/bin/mysql -uroot -e "FLUSH PRIVILEGES"

		source /essentials/load.sh
		stop_spinner $?
fi

if [ ! -z $DB ]; then
	echo "Creating database: \"$DB\""
		source /essentials/load.sh
                start_spinner
                sleep 2

		/usr/bin/mysql -uroot -e 'CREATE DATABASE '$DB''
		
		source /essentials/load.sh
                stop_spinner $?
fi

	echo "Creating the TPC-H Database ..."
		source /essentials/load.sh
		start_spinner
		sleep 2
	
		/usr/bin/mysql -u root -e "CREATE DATABASE tpch"
		/usr/bin/mysql -u root tpch < /essentials/tpch_test.sql

		source /essentials/load.sh
		stop_spinner $?
	
		/usr/bin/mysql -u root -e "optimize table tpch.LINEITEM"

	echo "Creating tables for phpmyadmin: ..."
	        source /essentials/load.sh
	        start_spinner
	        sleep 2

		/usr/bin/mysql -u root < /usr/share/doc/phpmyadmin/examples/create_tables.sql
		/usr/bin/mysql -u root -e 'GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'pma'@'localhost' IDENTIFIED BY "pmapassword"'

	        source /essentials/load.sh
	        stop_spinner $?

mysqladmin -uroot shutdown
while  nc -vz localhost 3306; do sleep 1; done

if [ ! -z $ROOTPASS ]; then
service mysql start
	echo "Creating password for root: ..."
	        source /essentials/load.sh
	        start_spinner
	        sleep 2
	
	       /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$ROOTPASS' WITH GRANT OPTION"

	        source /essentials/load.sh
	        stop_spinner $?
service mysql stop
fi

if [ ! -z $USER ]; then
	echo "========================================================================"
	echo "MySQL User: \"$USER\""
	echo "MySQL Password: \"$PASS\""
	echo "========================================================================"
fi

if [ ! -z $ROOTPASS ]; then
	echo "========================================================================"
	echo "MySQL root user password: \"$ROOTPASS\""
	echo "========================================================================"
fi

if [ ! -z $DB ]; then
	echo "========================================================================"
	echo "MySQL Database: \"$DB\""
	echo "========================================================================"
fi

cd /

service apache2 start && service mysql start && bash

