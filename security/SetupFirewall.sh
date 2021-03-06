#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Setup the firewall
#####################################################################################
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
##################################################################################
##################################################################################
#set -x #THIS MUST NOT BE SWITCHED ON DURING NORMAL USE, SCRIPT BREAK
##################################################################################

#This stream manipulation is necessary for correct functioning, please do not remove it
exec >${HOME}/logs/FIREWALL_CONFIGURATION.log
exec 2>&1
##################################################################################

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    exit
fi

. ${HOME}/providerscripts/utilities/SetupInfrastructureIPs.sh

SERVER_USER_PASSWORD="`/bin/ls ${HOME}/.ssh/SERVERUSERPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
SSH_PORT="`/bin/ls ${HOME}/.ssh/SSH_PORT:* | /usr/bin/awk -F':' '{print $NF}'`"

# Allow the building client to connect to the webserver
/bin/sleep 5

if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${BUILD_CLIENT_IP} | /bin/grep ALLOW`" = "" ] )
then
    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${BUILD_CLIENT_IP} to any port ${SSH_PORT}
fi

if ( [ -f ${HOME}/.ssh/PRODUCTION:1 ] )
then
   # autoscalerip="`/bin/ls ${HOME}/config/autoscalerip`"
   # publicautoscalerip="`/bin/ls ${HOME}/config/autoscalerpublicip`"
    
    for autoscalerip in `/bin/ls ${HOME}/config/autoscalerip`
    do
        if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${autoscalerip} | /bin/grep ALLOW`" = "" ] )
        then
           /bin/sleep 5
           /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${autoscalerip}
        fi
    done
    
    for publicautoscalerip in `/bin/ls ${HOME}/config/autoscalerpublicip`
    do
        if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${publicautoscalerip} | /bin/grep ALLOW`" = "" ] )
        then
            /bin/sleep 5
            /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${publicautoscalerip}
        fi
    done
fi


for ip in `/bin/ls ${HOME}/config/webserverips/`
do
    if ( [ "`/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw status | /bin/grep ${ip} | /bin/grep ALLOW`" = "" ] )
    then
        /bin/sleep 5
        /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw allow from ${ip} to any port ${SSH_PORT}
    fi
done


. ${HOME}/providerscripts/dns/SetupDNSFirewallRules.sh

/bin/sleep 5

#if ( [ "`/bin/cat ${HOME}/logs/FIREWALL_CONFIGURATION.log | /bin/grep 'Chain already exists.'`" != "" ] )
#then
#    /sbin/iptables -F
#    /sbin/iptables -X
#    /sbin/iptables -Z
#    /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/ufw --force reset
#    /bin/cp /dev/null ${HOME}/logs/FIREWALL_CONFIGURATION.log
#fi

/usr/sbin/ufw -f enable
