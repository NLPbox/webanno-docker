# This Dockerfile is using parts of the webanno admin guide
# found in https://webanno.github.io/webanno/releases/2.3.1/docs/admin-guide.html 

FROM tomcat:7-jre8

MAINTAINER Arne Neumann, Florian Kuhn 

RUN apt-get update
# Install tomcat utilities (we will need tomcat7-instance-create) and mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget mysql-server mysql-client tomcat7-user tomcat7-admin

# Copy webanno and mysql settings to tmp
COPY create_webanno_db.sql mysql-init /tmp/

# Setup mysql as depicted in the webanno admin guide
RUN service mysql stop
RUN mysqld_safe --init-file=/tmp/mysql-init &
RUN rm /tmp/mysql-init
RUN service mysql start && \
    mysql -u root < /tmp/create_webanno_db.sql

WORKDIR /opt
# Download the latest webanno 3 release. change the path accordingly if updated
RUN wget --no-check-certificate  https://github.com/webanno/webanno/releases/download/webanno-3.0.0-beta-4/webanno-webapp-3.0.0-beta-4.war 

# Create a tomcat7 instance of webanno to operate on port 18080 as
# shown in the official admin guide
RUN tomcat7-instance-create -p 18080 -c 18005 webanno && \
    chown -R www-data /opt/webanno
# Rename the webanno webapp 
COPY webanno_initd /etc/init.d/webanno
RUN mv /opt/webanno-webapp-3.0.0-beta-4.war /opt/webanno/webapps/webanno.war
# Setup webanno as a service 
RUN chmod +x /etc/init.d/webanno
RUN update-rc.d webanno defaults
RUN mkdir /srv/webanno

COPY settings.properties /srv/webanno/settings.properties
RUN chown -R www-data /srv/webanno

EXPOSE 18080

# If you wish minimal some editor, telnet and text-browser functionality
# for interactive mode in docker, you can uncomment the following line: 
# RUN apt-get install -y nano telnet w3m

# Start the webanno service and continously tail the tomcat log file output
# to the shell so the container does not shutdown immediatly after command execution
# and keeps running. Moreover, log output tells you if everything went ok 
# The terminal be killed while the container and thus webanno remains active.
CMD bash /opt/webanno/bin/startup.sh && tail -f /opt/webanno/logs/catalina.out 
