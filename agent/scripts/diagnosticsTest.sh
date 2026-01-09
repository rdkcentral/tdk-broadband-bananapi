#! /bin/bash
##########################################################################
# If not stated otherwise in this file or this component's LICENSE
# file the following copyright and licenses apply:
#
# Copyright 2018 RDK Management
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

export TDK_LOGGER_PATH=/nvram/TDK/
source /etc/tdk_platform.properties

echo "UPTIME:" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo "--------" >> $TDK_LOGGER_PATH/device_diagnostics.log
uptime >> $TDK_LOGGER_PATH/device_diagnostics.log

echo -e "\nCCSP PROCESSESS RUNNING:" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo "----------------------" >> $TDK_LOGGER_PATH/device_diagnostics.log

for process in $(echo $CCSP_PROCESS | sed "s/,/ /g")
do
    OUTPUT=$(top -b -n1 | grep $process | grep -v "grep")
    if [ $? -eq 0 ]; then
        echo $OUTPUT >> $TDK_LOGGER_PATH/device_diagnostics.log
    else
        echo "$process is not running" >> $TDK_LOGGER_PATH/device_diagnostics.log
    fi
done

echo "----------------------" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo -e "\n The following processes have two instances:" >> $TDK_LOGGER_PATH/device_diagnostics.log

for process in $(echo $CCSP_PROCESS | sed "s/,/ /g")
do
    OUTPUT=$(ps  | grep  $process | grep -v "grep"| wc -l)
    if [ $OUTPUT -gt 1 ]; then
        echo $process >> $TDK_LOGGER_PATH/device_diagnostics.log
    fi
done

echo "----------------------" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo -e "\n The following processes are not up:" >> $TDK_LOGGER_PATH/device_diagnostics.log

for process in $(echo $CCSP_PROCESS | sed "s/,/ /g")
do

    OUTPUT=$(pidof $process)
    if [ $OUTPUT -eq " " ]; then
        echo $process >> $TDK_LOGGER_PATH/device_diagnostics.log
    fi
done

echo "----------------------" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo -e "\n The following processes were restarted :" >> $TDK_LOGGER_PATH/device_diagnostics.log

echo $(grep -rin "restart" /rdklogs/logs/)

echo "----------------------" >> $TDK_LOGGER_PATH/device_diagnostics.log
echo -e "\n Checking if the device is in router mode :" >> $TDK_LOGGER_PATH/device_diagnostics.log
OUTPUT=$(dmcli eRT getv Device.X_CISCO_COM_DeviceControl.LanManagementEntry.1.LanMode | grep "value" | cut -f3 -d":" | cut -f2 -d" ")

echo "The device is in $OUTPUT mode ">> $TDK_LOGGER_PATH/device_diagnostics.log

if [ "$OUTPUT" != "router" ] ; then
   OUTPUT=$(dmcli eRT setv Device.X_CISCO_COM_DeviceControl.LanManagementEntry.1.LanMode string "router" | grep "value" | cut -f3 -d":" | cut -f2 -d" ")

   sleep 90
   OUTPUT=$(dmcli eRT getv Device.X_CISCO_COM_DeviceControl.LanManagementEntry.1.LanMode | grep "value" | cut -f3 -d":" | cut -f2 -d" ")
   if [ "$OUTPUT" = "router" ]; then
      echo "DUT set to router mode successfully">> $TDK_LOGGER_PATH/device_diagnostics.log
   else
       echo "Failed to set DUT to router mode successfully">> $TDK_LOGGER_PATH/device_diagnostics.log
   fi
fi
