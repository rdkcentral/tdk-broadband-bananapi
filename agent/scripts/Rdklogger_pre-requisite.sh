#!/bin/bash
##########################################################################
# If not stated otherwise in this file or this component's LICENSE
# file the following copyright and licenses apply:
#
# Copyright 2025 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

export LOG4C_RCPATH=/nvram/
export LOG_PATH=/rdklogs/logs/
export TDK_LOGGER_PATH=/nvram/TDK/

echo "Enter Rdklogger_pre-requisite"

count=0
MAX_RETRY=5

#Wait for /nvram to be mounted as RW before copying /etc/log4crc to /nvram.
while [ $count -lt $MAX_RETRY ]
do
        echo "Retry Count:" $count
        if [ -w "/nvram" ]; then
                echo "nvram is mounted as Read Write"
                if [ -f "/etc/log4crc" ]; then
                        echo "copy /etc/log4crc to LOG4C_RCPATH path"
                        cp /etc/log4crc $LOG4C_RCPATH
			CONTENT='<rollingpolicy name="TEST_rollingpolicy" type="sizewin" maxsize="2097152" maxnum="2"/>\n<appender name="RI_TESTrollingfileappender" type="rollingfile" logdir="/rdklogs/logs/" prefix="TESTLog.txt" layout="comcast_dated" rollingpolicy="TEST_rollingpolicy"/>\n<category name="RI.TEST" priority="debug" appender="RI_TESTrollingfileappender"/>\n<category name="RI.Stack.TEST" priority="debug" appender="RI_TESTrollingfileappender"/>\n<category name="RI.Stack.LOG.RDK.TEST" priority="debug" appender="RI_TESTrollingfileappender"/>'
                        C=$(echo $CONTENT | sed 's/\//\\\//g' | sed 's/\"/\\\"/g')
                        sed -i "/<\/log4c>/ s/.*/${C}\n&/" $LOG4C_RCPATH/log4crc
                        if [ -d "$TDK_LOGGER_PATH" ] ; then
                                echo "TDK folder already exists under /nvram"
                        else
                                echo "Create TDK folder under /nvram for TDK logging"
                                mkdir $TDK_LOGGER_PATH
                        fi
                else
                        echo "/etc/log4crc not found"
                fi
                break;
        else
                echo "nvram is not yet mounted or nvram is mounted as Read Only. Check after 5 seconds"
                sleep 5
        fi
        count=`expr $count + 1`
done

if [ $count -eq $MAX_RETRY ]; then
        echo "/etc/log4crc not found or nvram is not yet mounted or nvram is mounted as Read Only. Continue to start TDK Agent"
fi

echo "Exit Rdklogger_pre-requisite"

