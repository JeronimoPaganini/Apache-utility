#!/bin/bash 
# shev92k70 (Jeronimo)

_zenity="/usr/bin/zenity"
_out="/tmp/whois.output.$$"
while [ "$(id -u)" != "0" ];
do
	PASSWD="$(zenity --password --title 'For create VirtualHost')\n"
    if [ $? -eq 1 ]; 
    then
    	${_zenity} --title "Canceled" --info --text "Canceled operation"
        exit 6;
    elif [ $? -eq 5 ]; 
    then
    	${_zenity} --title "Canceled" --info --text "Timeout operation"
    	exit 7;
    fi
	if [ ! -z $PASSWD ]
	then
		res="$(echo -e $PASSWD | sudo -S whoami)";
		if echo -e $res | grep -q "root"
		then	
			site_dir="$(echo -e $PASSWD | sudo -S zenity --file-selection --directory --title 'Select the project directory')"
			if [ ! -z $site_dir ]; 
			then
				domain=$(${_zenity} --width=250 --height=100 --title  "Enter domain" \
				            --entry --text "Please enter domain name" )
				if [ ! -z $domain ];
				then
					email=$(${_zenity} --width=250 --height=100 --title  "Email administrator" \
				            --entry --text "Please enter administrator email or press OK to move next" )
					if [ -z $email ];
					then
						email="admin@admin.com"
					fi
					if zenity --width=250 --height=100 --question --text="Create log-directory in project directory?"; 
					then
					    yn="Yes"
					    log=$site_dir
					else
					    yn="No"
					fi
					if zenity --width=450 --height=200 --title="Create VirtualHost with this settings?" \
						--question --text "Settings VirtualHost\nProject directory: $site_dir\nDomain name: $domain\nAdministrator email: $email\nCreate log directory: $yn"; 
					then				
					    echo -e $PASSWD | sudo -S bash -c "touch /etc/apache2/sites-available/$domain.conf"
						if [ ! -z $log ]
						then
							log="ErrorLog $site_dir/logs/error.log"
							echo -e $PASSWD | sudo -S bash -c "mkdir $site_dir/logs"
							echo -e $PASSWD | sudo -S bash -c "touch $site_dir/logs/error.log"
						fi		    
						echo -e $PASSWD | sudo -S bash -c "echo '
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
						' >> /etc/apache2/sites-available/$domain.conf"
						echo -e $PASSWD | sudo -S bash -c "a2ensite $domain"
						echo -e $PASSWD | sudo -S bash -c "echo '127.0.0.1 $domain' >> /etc/hosts"
						if zenity --question --text="Reload apche2?"; 
						then
							echo -e $PASSWD | sudo -S  service apache2 reload 2>&1 | zenity --text-info --height=500 --width=400 --title="Progress status";
							${_zenity} --info --text "VirtualHost successfully created!"
							exit 3;			
						else
							${_zenity} --info --text "VirtualHost successfully created, settings will take effect after restarting the Apache server"
							exit 4;				
						fi											
					else
					    ${_zenity} --info --text "Abort operation"
					    exit 5;
					fi			
				else
					${_zenity} --width=250 --height=100 --title "Operation aborted." --info --text "Domain name is not entered."
					exit 2;
				fi
			else
				${_zenity} --width=250 --height=100 --title "Operation aborted." --info --text "Project directory is not selected."
				exit 1;
			fi
		else
			${_zenity} --error --text "Wrong root password"
		fi
	else
		${_zenity} --error --text "Password can not be empty"
	fi
done