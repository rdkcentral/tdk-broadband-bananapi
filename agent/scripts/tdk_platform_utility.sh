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

# Check whether the process is running
checkProcess()
{
    ps | grep $processName | grep -v grep |grep -v checkProcess | awk '{ print $1}'
}

# Get the process ID and kill the process
killProcess()
{
   kill -9 `ps | grep $processName | grep -v grep |grep -v killProcess | awk '{ print $1}'`
}

#get the MAC address of the device
getCMMACAddress()
{
    macaddress=`ifconfig erouter0 | grep HWaddr | awk '{ print $5 }'`
    echo $macaddress
}

#Start the DNS queries and check the query result status after the sleep
getQueryResult()
{
    `dmcli eRT setv Device.Diagnostics.X_RDK_DNSInternet.WANInterface.$((index)).QueryNow bool true > /dev/null`
    usleep $((sleepTime))
    result=`dmcli eRT getv Device.Diagnostics.X_RDK_DNSInternet.WANInterface.$((index)).QueryNowResult | grep value |  awk '{print $5}' | tr '\n' ' '`
    echo $result
}

# Store the arguments to a variable
event=$1
processName=$2
sleepTime=$2
index=$3

# Invoke the function based on the argument passed
case $event in
   "checkProcess")
        checkProcess;;
   "killProcess")
        killProcess;;
   "getCMMACAddress")
        getCMMACAddress;;
   "getQueryResult")
        getQueryResult;;
   *) echo "Invalid Argument passed";;
esac
