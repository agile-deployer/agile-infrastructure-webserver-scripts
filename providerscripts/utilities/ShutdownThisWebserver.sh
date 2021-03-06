#!/bin/sh
################################################################################################
# Author: Peter Winter
# Date  : 9/4/2016
# Description : Shutdown this websever, removing its IP from cloudflare NB: shutdown -h doesn't
# work from linodes and needs bespoke process because, linodes have something called "lasie"
# monitoring the linodes and it restarts them whenever they are shutdown. They have to be
# explicitly shutdown
################################################################################################
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
#################################################################################################
#################################################################################################
#set -x

/bin/echo "${0} `/bin/date`: This webserver is shutting down" >> ${HOME}/logs/MonitoringLog.dat

/bin/echo "Shutting down a webserver, please wait whilst I clean the place up first"

#You can add any additional shutdown procedures you need for your webserver here.
#There are two places a webserver should be shutdown from, the autoscaler as part of a "scale down" event and
#the build client as part of a manual "shutdown" of the infrastructure. Please note, on a shutdown, the
#webroot of the webserver is not preserved. There are backups every hour and that is what you will need to
#reference to be able to restore the latest webroot. If you really need a backup of your webroot which is just before shutdown
#then you can utilise the manual backup script which is stored in ${HOME}/ManualBackup.sh of your webserver
if ( [ "$1" = "backup" ] )
then
    BUILD_IDENTIFIER="`/bin/ls ${HOME}/.ssh/BUILDIDENTIFIER:* | /usr/bin/awk -F':' '{print $NF}'`"
    ${HOME}/providerscripts/git/Backup.sh "HOURLY" ${BUILD_IDENTIFIER} > /dev/null 2>&1
    ${HOME}/providerscripts/datastore/BackupEFSToDatastore.sh
fi

ip="`${HOME}/providerscripts/utilities/GetIP.sh`"

if ( [ -f ${HOME}/config/bootedwebserverips/${ip} ] )
then
    /bin/rm ${HOME}/config/bootedwebserverips/${ip}
fi

if ( [ -f ${HOME}/config/webserverpublicips/${ip} ] )
then
    /bin/rm ${HOME}/config/webserverpublicips/${ip}
fi

if ( [ -f ${HOME}/config/webserverips/${ip} ] )
then
    /bin/rm ${HOME}/config/webserverips/${ip}
fi

${HOME}/providerscripts/email/SendEmail.sh "${period} A Webserver with IP: `${HOME}/providerscripts/utilities/GetIP.sh` has been shutdown" "Webserver has been shut down"

#Note, we don't call the shutdown command here, on purpose, we just destroy the VM because we have cleaned it up as much as we need to

