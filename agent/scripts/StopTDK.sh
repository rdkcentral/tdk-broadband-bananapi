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
#

echo "Stopping TDK Agent.."
export TDK_PATH=/usr/ccsp/tdk

sleep 1

source $TDK_PATH/Rdklogger_post-requisite.sh

#Killing inactive TDK processes
ps | grep "TDKagentMonitor" | grep -v "grep" | awk '{print $2}' | xargs kill -9 >& /dev/null
sleep 1
ps | grep "tdk" | grep -v "grep" | awk '{print $2}' | xargs kill -9 >& /dev/null
ps | grep "tftp" | grep -v "grep" | awk '{print $2}' | xargs kill -9 >& /dev/null
ps | grep "tdk_firewall_service" | grep -v "grep" | awk '{print $2}' | xargs kill -9 >& /dev/null
sleep 2

echo "Done"
