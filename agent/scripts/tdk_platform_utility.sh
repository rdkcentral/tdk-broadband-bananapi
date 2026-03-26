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
arg4=$4

# Source platform properties
PLATFORM_PROPERTIES=/etc/tdk_platform.properties
if [ -f "$PLATFORM_PROPERTIES" ]; then
    . $PLATFORM_PROPERTIES
fi

# Get the ip link show output for the MLD interface (WiFi 7 Multi-Link Device)
getMLDInterfaceStatus()
{
    mldStatus=`ip link show $MLD_INTERFACE | grep $MLD_INTERFACE`
    echo $mldStatus
}

# Get ip link show output for MLD interface including bridge and state info
getMLDInterfaceBridgeStatus()
{
    bridgeStatus=`ip link show $MLD_INTERFACE | grep $MLD_INTERFACE`
    echo $bridgeStatus
}

# Get HWaddr of MLD interface from ifconfig
getMLDIfconfigHWAddr()
{
    hwaddr=`ifconfig $MLD_INTERFACE | grep HWaddr | awk '{ print $5 }'`
    echo $hwaddr
}

# Get addr of MLD interface from iw dev info
getMLDIwAddr()
{
    iwaddr=`iw $MLD_INTERFACE info | grep "addr" | head -1 | awk '{ print $2 }'`
    echo $iwaddr
}

# Get SSID configured on MLD interface from iw dev info
getMLDSSID()
{
    ssid=`iw $MLD_INTERFACE info | grep ssid`
    echo $ssid
}

# Get iw mld0 info output for a specific link ID
# Arg: linkId
getMLDLinkInfo()
{
    linkId=$4
    linkInfo=`iw $MLD_INTERFACE info | grep "link ID  $linkId"`
    echo $linkInfo
}

getMLDLinkAddr()
{
    linkAddr=`iw $MLD_INTERFACE info | grep "link ID  $arg4 " | awk '{print $NF}'`
    echo $linkAddr
}

getMLDLinkChannel()
{
    linkChannel=`iw $MLD_INTERFACE info | awk "/- link ID  $arg4 /{found=1} found && /channel/{print \$2; found=0}" | head -1`
    echo $linkChannel
}

getRadioIfHWAddr()
{
    hwaddr=`ifconfig $arg4 | grep -i HWaddr | awk '{ print $5 }'`
    echo $hwaddr
}

# Get Channel for a given radio index (1-based) from dmcli
# Arg: radioIndex
getRadioChannel()
{
    radioIndex=$4
    channel=`dmcli eRT getv Device.WiFi.Radio.$radioIndex.Channel | grep value | awk '{ print $NF }'`
    echo $channel
}

# Get OperatingChannelBandwidth for a given radio index (1-based) from dmcli
# Arg: radioIndex
getRadioBandwidth()
{
    radioIndex=$4
    bw=`dmcli eRT getv Device.WiFi.Radio.$radioIndex.OperatingChannelBandwidth | grep value | awk '{ print $NF }'`
    echo $bw
}

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
   "getMLDInterfaceStatus")
        getMLDInterfaceStatus;;
   "getMLDInterfaceBridgeStatus")
        getMLDInterfaceBridgeStatus;;
   "getMLDIfconfigHWAddr")
        getMLDIfconfigHWAddr;;
   "getMLDIwAddr")
        getMLDIwAddr;;
   "getMLDSSID")
        getMLDSSID;;
   "getMLDLinkInfo")
        getMLDLinkInfo;;
   "getMLDLinkAddr")
        getMLDLinkAddr;;
   "getMLDLinkChannel")
        getMLDLinkChannel;;
   "getRadioIfHWAddr")
        getRadioIfHWAddr;;
   "getRadioChannel")
        getRadioChannel;;
   "getRadioBandwidth")
        getRadioBandwidth;;
   *) echo "Invalid Argument passed";;
esac
