FROM phusion/baseimage:latest
MAINTAINER Gavin Mogan "gavin@gavinmogan.com"
ENV OC_VERSION 8.2.1
RUN apt-get -y update
RUN apt-get install -y apache2 php5 php5-gd php-xml-parser php5-intl php5-mysqlnd php5-json php5-mcrypt smbclient curl libcurl3 php5-curl bzip2 wget
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN curl -L https://download.owncloud.org/community/owncloud-$OC_VERSION.tar.bz2 | tar jx -C /var/www/
RUN mkdir -p /var/www/owncloud/apps/notes

# Create data Directory
RUN mkdir /var/www/owncloud/data

# Setup apache
ADD ./001-owncloud.conf /etc/apache2/sites-available/
RUN rm -f /etc/apache2/sites-enabled/000*
RUN ln -s /etc/apache2/sites-available/001-owncloud.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite

# startup
ADD rc.local /etc/rc.local
RUN chown root:root /etc/rc.local

# Install all the plugins
RUN curl -L https://github.com/owncloud/notes/archive/v2.0.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/notes
RUN mkdir -p /var/www/owncloud/apps/ownnote
RUN curl -L https://github.com/Fmstrat/ownnote/archive/ownNote-1.05.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/ownnote
RUN mkdir -p /var/www/owncloud/apps/ocsms
RUN curl -L https://github.com/nerzhul/ocsms/archive/v1.5.0.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/ocsms
RUN mkdir -p /var/www/owncloud/apps/qownnotesapi
RUN curl -L https://apps.owncloud.com/CONTENT/content-files/173817-qownnotesapi.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/qownnotesapi
RUN mkdir -p /var/www/owncloud/apps/contacts
RUN curl -L https://github.com/owncloud/contacts/archive/v0.5.0.0.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/contacts
RUN mkdir -p /var/www/owncloud/apps/tasks
RUN curl -L https://github.com/owncloud/tasks/archive/v0.8.1.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/tasks
RUN mkdir -p /var/www/owncloud/apps/calendar
RUN curl -L https://github.com/owncloud/calendar/archive/v0.8.1.tar.gz | tar xz --strip-components=1 -C /var/www/owncloud/apps/calendar

# lock down ownership of everything
RUN chown -R www-data:www-data /var/www/owncloud

VOLUME ["/var/www/owncloud/data", "/var/www/owncloud/config"]
EXPOSE 80
CMD ["/sbin/my_init"]
