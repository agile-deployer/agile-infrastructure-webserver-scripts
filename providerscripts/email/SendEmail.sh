#!/bin/sh
################################################################################
# Description: This script is used for sending system emails. Scripts can make use
# of this whenever they need to send a system notification. Notifications are always
# sent to the same email address which is defined at build time.
# Date: 16-11-2016
# Author: Peter Winter
##################################################################################
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
#####################################################################################
#####################################################################################
#set -x

subject="$1"
message="$2"
fromaddress="`/bin/ls ${HOME}/.ssh/FROMADDRESS:* | /usr/bin/awk -F':' '{print $NF}'`"
toaddress="`/bin/ls ${HOME}/.ssh/TOADDRESS:* | /usr/bin/awk -F':' '{print $NF}'`"
username="`/bin/ls ${HOME}/.ssh/EMAILUSERNAME:* | /usr/bin/awk -F':' '{print $NF}'`"
password="`/bin/ls ${HOME}/.ssh/EMAILPASSWORD:* | /usr/bin/awk -F':' '{print $NF}'`"
emailprovider="`/bin/ls ${HOME}/.ssh/EMAILPROVIDER:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${password}" = "" ] )
then
    password="`/bin/cat ${HOME}/.ssh/SYSTEMEMAILPASSWORD.dat`"
fi

if ( [ "${emailprovider}" = "1" ] )
then
    /usr/bin/sendemail -o tls=no -f ${fromaddress} -t ${toaddress} -s smtp-pulse.com:2525 -xu ${username} -xp ${password} -u "${subject}`/bin/date`" -m ${message}
fi
if ( [ "${emailprovider}" = "2" ] )
then
    /usr/bin/sendemail -o tls=yes -f ${fromaddress} -t ${toaddress} -s smtp.gmail.com:587 -xu ${username} -xp ${password} -u "${subject} `/bin/date`" -m ${message}
fi
if ( [ "${emailprovider}" = "3" ] )
then
    /usr/bin/sendemail -o tls=yes -f ${fromaddress} -t ${toaddress} -s email-smtp.eu-west-1.amazonaws.com -xu ${username} -xp ${password} -u "${subject} `/bin/date`" -m ${message}
fi
