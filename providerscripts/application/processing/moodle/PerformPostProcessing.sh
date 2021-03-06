#!/bin/sh
#################################################################################################
# Description: If your application requires any post processing to be performed,
# then, this is the place to put it. Post processing is considered to be any processing
# which is required after the application is considered installed.
# This is the post processing for a moodle install. If you examine the code, you will
# find that this script is called from the build client over ssh once it considers
# that the application has been fully installed.
#   ***********IMPORTANT*****************
#   These post processing scipts are not run using sudo as is normally the case, this is
#   because of issues with stdin and so on. So if a command requires privilege than sudo
#   must be used on a command by command basis. This is true for all PerformPostProcessing Scripts
#   ***********IMPORTANT*****************
# Author: Peter Winter
# Date: 04/01/2017
#################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

SERVER_USER="`/bin/ls ${HOME}/.ssh/SERVERUSER:* | /usr/bin/awk -F':' '{print $NF}'`"
SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
WEBSITEURL="`/bin/ls ${HOME}/.ssh/WEBSITEURL:* | /usr/bin/awk -F':' '{pring $NF}'`"
DB_PORT="`/bin/ls ${HOME}/.ssh/DB_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"
SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E"
BUILD_ARCHIVE_CHOICE="`/bin/ls ${HOME}/.ssh/BUILDARCHIVECHOICE:* | /usr/bin/awk -F':' '{print $NF}'`"

credentials_available=""
database_available=""
configset=""

while ( [ "${credentials_available}" = "" ] || [ "${database_available}" = "" ] || [ "${configset}" = "" ] )
do
    credentials_available="`command="${SUDO} /bin/ls ${HOME}/config/credentials/shit" && eval ${command}`"
    database_available="`command="${SUDO} /bin/ls ${HOME}/config/databaseip" && eval ${command}`"
    configset="`command="${SUDO} /bin/ls ${HOME}/runtime/VIRGINCONFIGSET" && eval ${command}`"
    if ( [ "${configset}" = "" ] )
    then
        configset="`command="${SUDO} /bin/ls ${HOME}/runtime/APPLICATION_DB_CONFIGURED" && eval ${command}`"
    fi
    /bin/sleep 10
done

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] && [ -f  ${HOME}/runtime/SSHTUNNELCONFIGURED ] )
then
    host="127.0.0.1"
elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] )
then
    host="`/bin/ls ${HOME}/.ssh/DBaaSHOSTNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
else
    host="`command="${SUDO} /bin/ls ${HOME}/config/databaseip" && eval ${command}`"
fi

username="`command="${SUDO} /bin/sed '3q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
password="`command="${SUDO} /bin/sed '2q;d' ${HOME}/config/credentials/shit" && eval ${command}`"
database="`command="${SUDO} /bin/sed '1q;d' ${HOME}/config/credentials/shit" && eval ${command}`"

if ( [ ! -d /var/www/html/moodledata ] )
then
    command="${SUDO} /bin/mkdir -p /var/www/html/moodledata/filedir" && eval ${command}
    command="${SUDO} /bin/chmod -R 755 /var/www/html/moodledata" && eval ${command}
    command="${SUDO} /bin/chown -R www-data.www-data /var/www/html/moodledata" && eval ${command}
fi


#This is needed when the autoscaler checks for the webserver being up. Moodle is a bit odd, so we have to put this in

/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sh -c '/bin/echo "<?php
echo \"hello, you need to surf to ${WEBSITEURL}/moodle \"
?>" > /var/www/html/index.php'

if ( ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS-secured ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:DBaaS ] ) && ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] ||  [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] ) )
then

    /bin/echo "This will vary by provider. Moodle requires that the database is set up in a specific way. This requires extra privileges"
    /bin/echo "Which the for some providers, only the root user has. If you are with AWS, for example, you should have already configured"
    /bin/echo "These parameters using a parameter group so you don't need to do anything. With rackspace, for example, the root user is"
    /bin/echo "not activated by default and so we need to activate the root user. To do this, for rackspace, please refer to helperscripts/EnableRootForRackspaceCloudDatabase.sh"
    /bin/echo "And glean the root password form the output. This process will vary by DBaaS provider and clearly, I can't test them all"
    /bin/echo
    /bin/echo "So, I hope that is clear. If the parameters haven't been set when you deployed the database, you will need to tell me the master"
    /bin/echo "username and the master password for your database so that I can set them now for you so, let's push on"
    /bin/echo
    /bin/echo "Please enter the master username for your database (probably root)"
    read master_username
    /bin/echo "Please enter the master password for your database (for rackspace please refer to helperscripts/EnableRootForRackspaceCloudDatabase.sh)"
    read root_password

 #   /usr/bin/mysql -A -u ${master_username} -p${master_password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL innodb_file_per_table=ON;"
 #   /usr/bin/mysql -A -u ${master_username} -p${master_password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL binlog_format = 'MIXED';"


#    if ( [ "$?" != "0" ] )
#    then
#        /usr/bin/mysql -A -u ${username} -p${password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL innodb_file_per_table=ON;"
  #      /usr/bin/mysql -A -u ${username} -p${password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL binlog_format = 'MIXED';"
#    fi
#elif ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] ||  [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
#then
   # /usr/bin/mysql -A -u ${username} -p${password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL innodb_file_per_table=ON;"
#    /usr/bin/mysql -A -u ${username} -p${password} ${database} --host="${host}" --port="${DB_PORT}" -e "SET GLOBAL binlog_format = 'MIXED';"
#fi

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
    #Set a default admin password for a moodle install. Should be changed by the new administrator.
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sed -i "s/^\$username.*/\$username=\"admin\"/" /var/www/html/moodle/admin/cli/reset_password.php
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/sed -i "s/^\$password.*/\$password=\"123QQwe!!\"/" /var/www/html/moodle/admin/cli/reset_password.php
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/bin/php /var/www/html/moodle/admin/cli/install_database.php --lang=en --adminuser="admin" --adminpass="test1234" --agree-license
    #We have to keep trying until our moodle config file is setup with the database credentials. This will fail until it is which takes a few minutes.
    while ( [ "$?" != "0" ] )
    do
        /bin/echo "#############################################################################################################################################"
        /bin/echo "Ignore any db connection warnings, they will pass after things have warmed up. Until then, working on your database, please be patient......"
        /bin/echo "#############################################################################################################################################"
        /bin/sleep 30
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/bin/php /var/www/html/moodle/admin/cli/install_database.php --lang=en --adminuser="admin" --adminpass="test1234" --agree-license
    done
fi

if ( ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] ) && [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/bin/php /var/www/html/moodle/admin/cli/mysql_engine.php --engine=InnoDB
fi

/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /bin/touch /home/${SERVER_USER}/config/APPLICATION_INSTALLED

if ( [ ! -f /home/${SERVER_USER}/.ssh/BUILDARCHIVECHOICE:virgin ] && [ ! -f /home/${SERVER_USER}/.ssh/BUILDARCHIVECHOICE:baseline ] )
then
if ( ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:MySQL ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] ) ||
     ( [ -f ${HOME}/.ssh/DATABASEDBaaSINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] ) )
then
    then
        if ( [ "`/usr/bin/mysql -A -u ${username} -p${password} ${database} --host="${host}" --port="${DB_PORT}" -e "show tables;" | /bin/grep 'zzzz' | /usr/bin/wc -l`" != "1" ] )
        then
            /bin/echo "Looks like there was a problem installing the database for you application. It could be a partial install, please investigate upon build completion"
            /bin/echo "Press <enter> to continue with the build"
        else
            /bin/echo "Database has been successfully validated..."
        fi
    fi
fi
