#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: Check if the assets directories are mounted - essential for integrity
# of the build. This is called from the build client at the end of the build process
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
#######################################################################################
#######################################################################################
#set -x

mounted="1"

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
    mounted="0"
fi

if ( [ -f ${HOME}/.ssh/PERSISTASSETSTOCLOUD:0 ] && [ "${mounted}" = "1" ] )
then
    /bin/echo "MOUNTED"
    exit
fi

assetsdirectories="`/bin/ls ${HOME}/.ssh/DIRECTORIESTOMOUNT:* | /usr/bin/awk -F':' '{ $1=""; print}' | /bin/sed 's/\./\//g' | /usr/bin/tr '\n' ' ' | /bin/sed 's/  / /g' | /bin/sed 's/config//g'`"

for assetsdirectory in ${assetsdirectories}
do
    if ( [ "`/usr/bin/file /var/www/html/${assetsdirectory} | /bin/grep -v "No such" | /bin/grep "directory" > /dev/null`" ] || [ "`/bin/mount | /bin/grep "/var/www/html/${assetsdirectory}"`" = "" ] )
    then
        mounted="0"
    fi
done

if ( [ "${mounted}" = "1" ] )
then
    /bin/echo "MOUNTED"
else
    /bin/echo "NOT MOUNTED"
fi
