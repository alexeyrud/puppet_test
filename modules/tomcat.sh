#!/bin/bash
wget -O /tmp/apache-tomcat-7.0.68.tar.gz http://apache.ip-connect.vn.ua/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz
sudo mkdir /opt/tomcat

sudo tar -xzvf /tmp/apache-tomcat-7.0.68.tar.gz -C /opt/tomcat --strip-components=1
sudo cp /vagrant/modules/tomcat /etc/init.d/tomcat
sudo cp /vagrant/modules/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml

sudo chmod 755 /etc/init.d/tomcat

sudo chkconfig --add tomcat
sudo chkconfig tomcat on

#sudo rm -rf /opt/tomcat/webapps/* 
sudo cp /vagrant/modules/petclinic.war /opt/tomcat/webapps/petclinic.war

 sudo service tomcat start 
	while [ ! -f /opt/tomcat/webapps/petclinic/WEB-INF/classes/spring/data-access.properties ] 
	do
	 sleep 1s
	done 
	sleep 5s
