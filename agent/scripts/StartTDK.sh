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

#Setting up environment to run TDK
export TDK_PATH=/usr/ccsp/tdk/
export TDK_BIN_PATH=/usr/bin/
export TDK_LOGGER_PATH=/nvram/TDK/
export TDK_PROPERTIES_PATH=/etc/
export PATH=$PATH:/usr/local/bin:$TDK_BIN_PATH
export TDK_LIB_PATH=$TDK_PATH/libs/
export LD_LIBRARY_PATH=$TDK_LOGGER_PATH/libs/:$TDK_PATH/libs/:/usr/local/lib/:/usr/local/Qt/lib/:/mnt/nfs/lib:/mnt/nfs/bin/target-snmp/lib/:/mnt/nfs/bin:/usr/local/lib/sa:$LD_LIBRARY_PATH

source $TDK_PATH/Rdklogger_pre-requisite.sh

export PATH HOME LD_LIBRARY_PATH
ulimit -c unlimited

echo "Going to check the iptable rules"
cd $TDK_PATH/
if [ -f "tdk_firewall_service.sh" ]
then
        echo "Enable iptable rules for TDK"
        sh tdk_firewall_service.sh &
fi

echo "Going to start Agent"
cd $TDK_BIN_PATH/
./rdk_tdk_agent_process &
sleep 5
status=`ps | grep tdk_agent | grep -v grep`
if [  "$status" ];
then
    echo "Starting Agent Monitor Process.."
    sleep 5
    cd $TDK_PATH/
    sh TDKagentMonitor.sh
fi


