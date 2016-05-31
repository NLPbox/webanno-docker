FROM tomcat:7-jre8

MAINTAINER Arne Neumann, Florian Kuhn 

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget mysql-server mysql-client tomcat7-user tomcat7-admin

COPY create_webanno_db.sql mysql-init /tmp/

RUN service mysql stop
RUN mysqld_safe --init-file=/tmp/mysql-init &
RUN rm /tmp/mysql-init
RUN service mysql start && \
    mysql -u root < /tmp/create_webanno_db.sql

RUN apt-get install -y curl

WORKDIR /opt

RUN wget --no-check-certificate  https://github.com/webanno/webanno/releases/download/webanno-3.0.0-beta-4/webanno-webapp-3.0.0-beta-4.war 

RUN tomcat7-instance-create -p 18080 -c 18005 webanno && \
    chown -R www-data /opt/webanno

COPY webanno_initd /etc/init.d/webanno
RUN mv /opt/webanno-webapp-3.0.0-beta-4.war /opt/webanno/webapps/webanno.war

RUN chmod +x /etc/init.d/webanno
RUN update-rc.d webanno defaults
RUN mkdir /srv/webanno

COPY settings.properties /srv/webanno/settings.properties
RUN chown -R www-data /srv/webanno

EXPOSE 18080

RUN apt-get install -y nano telnet w3m
CMD bash /opt/webanno/bin/startup.sh && tail -f /opt/webanno/logs/catalina.out
