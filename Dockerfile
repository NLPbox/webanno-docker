FROM debian:wheezy

MAINTAINER Florian Kuhn <kuhn@ids-mannheim.de>

RUN apt-get update
RUN apt-get install -y wget mysql-server mysql-client

# Add oracle java 7 repository
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get -y update
# Accept the Oracle Java license
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections
# Install Oracle Java
RUN apt-get -y install oracle-java8-installer


COPY create_webanno_db.sql mysql-init tmp/

RUN service mysql stop
RUN mysqld_safe --init-file=/tmp/mysql-init &
RUN rm /tmp/mysql-init
RUN service mysql start && \
    mysql -u root < /tmp/create_webanno_db.sql

RUN apt-get install -y curl

RUN apt-get install -y tomcat7 tomcat7-user
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/default/tomcat7

WORKDIR /opt

RUN wget --no-check-certificate  https://github.com/webanno/webanno/releases/download/webanno-3.0.0-beta-2/webanno-webapp-3.0.0-beta-2.war 
# RUN wget http://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war -P /var/lib/tomcat7/webapps

RUN tomcat7-instance-create -p 18080 -c 18005 webanno && \
    chown -R www-data /opt/webanno

COPY webanno_initd /etc/init.d/webanno
RUN mv /opt/webanno-webapp-3.0.0-beta-2.war /opt/webanno/webapps/webanno.war

RUN chmod +x /etc/init.d/webanno
RUN update-rc.d webanno defaults
RUN mkdir /srv/webanno

COPY settings.properties /srv/webanno/settings.properties
RUN chown -R www-data /srv/webanno

EXPOSE 18080

RUN apt-get install -y nano telnet w3m
COPY start_webanno.sh /tmp/
# RUN service tomcat7 start
CMD service tomcat7 start && tail -f /var/lib/tomcat7/logs/catalina.out && bash /tmp/start_webanno.sh
# tail -f /var/lib/tomcat7/logs/catalina.out
#ENTRYPOINT service webanno start
