FROM debian:squeeze

MAINTAINER Arne Neumann <nlpdocker.programming@arne.cl>

RUN apt-get update
RUN apt-get install -y wget mysql-server mysql-client

COPY create_webanno_db.sql mysql-init tmp/

RUN service mysql stop
RUN mysqld_safe --init-file=/tmp/mysql-init &
RUN rm /tmp/mysql-init
RUN service mysql start && \
    mysql -u root < /tmp/create_webanno_db.sql

RUN apt-get install -y curl

WORKDIR /opt
RUN wget --no-check-certificate https://bintray.com/artifact/download/webanno/downloads/webanno-webapp-2.3.1.war

RUN apt-get install -y tomcat7 tomcat7-user

RUN tomcat6-instance-create -p 18080 -c 18005 webanno && \
    chown -R www-data /opt/webanno

COPY webanno_initd /etc/init.d/webanno
RUN mv /opt/webanno-webapp-2.3.1.war /opt/webanno/webapps/webanno.war

RUN chmod +x /etc/init.d/webanno
RUN update-rc.d webanno defaults
RUN mkdir /srv/webanno

COPY settings.properties /srv/webanno/settings.properties
RUN chown -R www-data /srv/webanno

EXPOSE 18080

RUN apt-get install -y nano telnet w3m
COPY start_webanno.sh /tmp/
CMD /bin/sh /tmp/start_webanno.sh
#ENTRYPOINT service webanno start
