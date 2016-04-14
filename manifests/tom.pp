#Install Java
package { 'java-1.7.0-openjdk':
  	 ensure => installed,
	 }

#Set execute mode to install script
file     {'chmod_tomcat_install_script':
         ensure => 'file',
         path => '/vagrant/modules/tomcat.sh',
         owner => 'root',
         group => 'root',
         mode  => '0744', 
         }
  
#Run script for installing tomcat
exec     {'tomcat':   	
	 command => '/usr/bin/sudo /vagrant/modules/tomcat.sh',
         require => [File['chmod_tomcat_install_script'],Package['java-1.7.0-openjdk']]
	 }

#Run script for Iptaples (access tomcat server)
exec     {'add_iptables_chain':   	
	 command => '/sbin/iptables -I INPUT 4 -p tcp -m tcp --dport 8080 -j ACCEPT'
	 }

#Install Mysqld
package  {'mysql-server':
	 ensure => installed,
         }

#Start service mysqld
service  {'mysqld':
         ensure => running,
         enable => true,
         require => Package['mysql-server'],
         }
 
#Create DB petclinic
exec     {'create_mysql_db':
         command => '/usr/bin/mysql -uroot -e "create database petclinic;"',
         require => [Service['mysqld'],Exec['tomcat']]
         }

#Copy pom.xml
exec     {'update_pomxml':   	
 	 command => '/usr/bin/sudo /bin/cp /vagrant/modules/pom.xml /opt/tomcat/webapps/petclinic/META-INF/maven/pom.xml',
         require => [Exec['tomcat'],Exec['create_mysql_db']],
	 }

#Copy data-access.properties
exec     {'update_dataaccessprop':   	
 	 command => '/usr/bin/sudo /bin/cp /vagrant/modules/data-access.properties /opt/tomcat/webapps/petclinic/WEB-INF/classes/spring/data-access.properties',
	 require => Exec['update_pomxml'],
	 }

#Download mysql driver
exec     {'get_mysql_connector':   	
	 command => '/usr/bin/sudo /usr/bin/wget -O /tmp/mysql-connector-java-5.1.38.tar.gz  http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz',
         require => Exec['update_pomxml'],
	 }

#Copy mysql driver
exec     {'copy_mysql_connector':   	
	 command => '/usr/bin/sudo /bin/tar -xzvf /tmp/mysql-connector-java-5.1.38.tar.gz -C /opt/tomcat/webapps/petclinic/WEB-INF/lib/ mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar --strip-components=1',
         require => Exec['get_mysql_connector'],
	 }

#Stop petclinic apps
exec     {'stop_tomcat_app':   	
         command => '/usr/bin/sudo /usr/bin/curl --user tomcat:s3cret http://localhost:8080/manager/text/stop?path=/petclinic',
         require => [Exec['get_mysql_connector'],Exec['update_dataaccessprop'],Exec['copy_mysql_connector']],
         }

#Start petclinic apps
exec     {'start_tomcat_app':   	
         command => '/usr/bin/sudo /usr/bin/curl --user tomcat:s3cret http://localhost:8080/manager/text/start?path=/petclinic',
         require => Exec['stop_tomcat_app'],
         }
