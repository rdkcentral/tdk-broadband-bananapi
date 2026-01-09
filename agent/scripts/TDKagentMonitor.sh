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

loop=1
sleep 60

export TDK_LOGGER_PATH=/nvram/TDK/

if [ -f $TDK_LOGGER_PATH/monitorcrash.log ]; then

        l=`wc -l < $TDK_LOGGER_PATH/monitorcrash.log`

        if [ "$l" -gt 30 ];then
                sed -i '1d' $TDK_LOGGER_PATH/monitorcrash.log
        fi
fi

# To monitor TDK Agent process and reboot box on its crash
while [ $loop -eq 1 ]
do
   status=`ps | grep tdk_agent_monitor | grep -v grep`
   agentPort=`netstat -tupln | grep "8087" | awk {'print$7'}`
   devicePort=`netstat -tupln | grep "8088" | awk {'print$7'}`
   if [[ ! "$status" ]] || [[ $agentPort != *"tdk_agent"* ]] || [[ $devicePort != *"tdk_agent"* ]]
   then
       echo "TDK agent monitor crashed or TDK agent not listening on port 8087/8088.. Box going for Reboot.."
       echo $(date) >> $TDK_LOGGER_PATH/monitorcrash.log
       sleep 10 && reboot
   fi
   sleep 5

done
