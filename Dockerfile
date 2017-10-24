FROM ubuntu:16.04
MAINTAINER Apuroop Naidu <apuroop.naidu>

ENV DEBIAN_FRONTEND noninteractive
ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**

COPY tpch_test.sql /mysql/tpch_test.sql
COPY run.sh /mysql/run.sh

#Updating and Installing resources
RUN apt-get -y update
RUN apt-get install -y \
        apt-utils \
        nano \
        curl \
        ftp \
        vim \
        sed \
        zip \
        unzip

#Installing Apache2
RUN apt-get -y install apache2
RUN update-rc.d apache2 enable

#Installing MySQL and setting the password as 12345
RUN echo 'mysql-server mysql-server/root_password password 12345' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password 12345' | debconf-set-selections
RUN apt-get -y install mysql-server --no-install-recommends
RUN sed -ie "s/^bind-address\s*=\s*127\.0\.0\.1$/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

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
RUN echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/app-password-confirm password 12345' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/mysql/admin-pass password 12345' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/mysql/app-pass password 12345' | debconf-set-selections
RUN echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
RUN apt-get -y install phpmyadmin --no-install-recommends

RUN mkdir -m777 /etc/tpch/
COPY index.php /var/www/html/
COPY run.sh /usr/sbin/
ADD TPC-H_SQL /etc/tpch/

RUN a2enmod rewrite && a2enconf phpmyadmin && phpenmod mcrypt && phpenmod mbstring
RUN ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
RUN chmod +x /usr/sbin/run.sh
RUN chown -R www-data:www-data /var/www/html
RUN chown -R mysql: /var/lib/mysql

RUN apt-get clean
VOLUME ["/var/log/mysql/", "/var/lib/mysql", "/var/log/apache2/", "/var/www/html"]

EXPOSE 80
EXPOSE 3306

ENTRYPOINT /usr/sbin/run.sh

