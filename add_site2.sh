#!/bin/bash 
# Jeronimo (Flexaspect)
if [ "$(id -u)" != "0" ]; then
   echo "This script need to be running from superuser rights"
   exit 0
fi
echo "Please enter project root directory:"
read site_dir
if [ ! -z $site_dir ]; 
then
	echo "Please enter domain name:"
	read domain
	if [ ! -z $domain ];
	then
		echo "Please enter administrator email or press enter to move next"
		read email
		if [ -z $email ];
		then
			email="admin@admin.com"
		fi
		while true; do
			echo "Create log-directory in project directory? (y/n)"
		    read yn
		    case $yn in
		        [Yy]* ) 
					yn="Yes"
					log=$site_dir
				break;;
		        [Nn]* ) 
					yn="No"
				break;;
		        * ) echo "Please answer Yes or No.";;
		    esac
		done
		echo "Settings VirtualHost:\n==============================="
		echo "Project directory: $site_dir"
		echo "Domain name: $domain"
		echo "Administrator email: $email"
		echo "Create log directory: $yn"
		echo "==============================="
		while true; do
			echo "Create VirtualHost with this settings? (Y/N)"
			read tyn
			case $tyn in
				[Yy]* ) 
				touch /etc/apache2/sites-available/$domain.conf
				if [ ! -z $log ]
				then
					log="ErrorLog $site_dir/logs/error.log"
					mkdir $site_dir/logs
					touch $site_dir/logs/error.log
				fi
				echo "
<VirtualHost *:80>
   ServerName $domain
   ServerAlias $domain
   ServerAdmin $email
   $log
   DocumentRoot  $site_dir
        <Directory "$site_dir">
		    Order allow,deny
		    Allow from all
		    Require all granted
		    AllowOverride All
        </Directory>
</VirtualHost>
				" >> /etc/apache2/sites-available/$domain.conf
				a2ensite $domain				
				#a2enconf /etc/apache2/sites-available/$domain
				echo "127.0.0.1 $domain" >> /etc/hosts
				while true; do
					echo "Reload apche2? (y/n)"
				    read yn
				    case $yn in
				        [Yy]* ) 
							service apache2 reload
							echo "VirtualHost successfully created!"
							exit 3
						break;;
				        [Nn]* ) 
							echo "VirtualHost successfully created, settings will take effect after restarting the Apache server"
							exit 4
						break;;
				        * ) echo "Please answer Yes or No.";;
				    esac
				done				
				break;;
		        [Nn]* ) echo "Abort operation ..."; exit;;
		        * ) echo "Please answer Yes or No";;							
			esac
		done		
	else
		echo "Domain name is not entered. Operation aborted."
		exit 2
	fi

else
	echo "Project directory is not entered. Operation aborted."
	exit 1
fi