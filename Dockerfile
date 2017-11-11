FROM ubuntu:16.04
MAINTAINER Apuroop Naidu <apuroop.naidu>

ENV DEBIAN_FRONTEND noninteractive

#Updating and Installing resources
RUN apt-get -y update && apt-get install -y apt-utils \
	nano \
        curl \
        ftp \
        vim \
        sed \
        zip \
        unzip \
	netcat-openbsd

#Installing Apache2
RUN apt-get -y install apache2

#Installing MySQL
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get -y install --force-yes \
	mysql-server-5.7 && \
	service mysql stop

#Installing PHP7.0 and dependencies
RUN apt-get install -y \
        php7.0 \
        7.0-bz2 \
        php7.0-cgi \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-dev \
        php7.0-enchant \
        php7.0-fpm \
        php7.0-gd \
        php7.0-gmp \
        php7.0-imap \
        php7.0-interbase \
        php7.0-intl \
	php7.0-json \
        php7.0-ldap \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-odbc \
        php7.0-opcache \
        php7.0-pgsql \
        php7.0-phpdbg \
        php7.0-pspell \
        php7.0-readline \
        php7.0-recode \
        php7.0-snmp \
        php7.0-sqlite3 \
        php7.0-sybase \
        php7.0-tidy \
        php7.0-xmlrpc \
        php7.0-xsl \
        libapache2-mod-php7.0

#Installing phpmyadmin and setting the password as 12345
RUN echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections && \
	echo 'phpmyadmin phpmyadmin/app-password-confirm password 12345' | debconf-set-selections && \
	echo 'phpmyadmin phpmyadmin/mysql/admin-pass password 12345' | debconf-set-selections && \
	echo 'phpmyadmin phpmyadmin/mysql/app-pass password 12345' | debconf-set-selections && \
	echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections && \
	apt-get -y install phpmyadmin --no-install-recommends

COPY index.php /var/www/html/
COPY tpch_test.sql /mysql/tpch_test.sql
ADD scripts /scripts
ADD scripts/run.sh /usr/local/bin/run.sh

RUN a2enmod rewrite && phpenmod mcrypt && phpenmod mbstring && \
	mkdir -m777 /etc/tpch/ && \
	ln -s /usr/share/phpmyadmin /var/www/phpmyadmin && \
	chmod +x /usr/local/bin/run.sh && \
	chown -R www-data:www-data /var/www/html && \
	chmod +x /scripts/*.sh && \
	apt-get clean

ADD TPC-H_SQL /etc/tpch/
ADD my.cnf /etc/mysql/conf.d/my.cnf

VOLUME ["/var/lib/mysql", "/etc/mysql"]

EXPOSE 80
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/run.sh"]
