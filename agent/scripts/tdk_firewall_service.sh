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

EROUTER_IF=erouter0
STATUS_PORT=8088
AGENT_PORT=8087
MONITOR_PORT=8090
loop=1
EROUTER_IP4=""
EROUTER_IP6=""

add_v4firewall_rule()
{
        #insert ipv4_firewall rule to enable comunication between TM and Test agent
        iptables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $STATUS_PORT -j ACCEPT
        iptables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $AGENT_PORT -j ACCEPT
        iptables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $MONITOR_PORT -j ACCEPT
}

add_v6firewall_rule()
{
        #insert ipv6_firewall rule to enable comunication between TM and Test agent
        ip6tables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $STATUS_PORT -j ACCEPT
        ip6tables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $AGENT_PORT -j ACCEPT
        ip6tables -I INPUT -i $EROUTER_IF -p tcp -m tcp --dport $MONITOR_PORT -j ACCEPT
}

start_firewall_service()
{
        while [ $loop -eq 1 ]
        do
                check_v4_rule=`iptables-save | grep -E "$EROUTER_IF -p tcp -m tcp --dport $STATUS_PORT -j ACCEPT"`
                check_v6_rule=`ip6tables-save | grep -E "$EROUTER_IF -p tcp -m tcp --dport $STATUS_PORT -j ACCEPT"`

                if [ "$check_v4_rule" == "" ];then
                        echo "tdk_firewall_service.sh: v4 rule is missing in iptables, adding now"
                        add_v4firewall_rule
                fi

                if [ "$check_v6_rule" == "" ];then
                        echo "tdk_firewall_service.sh: v6 rule is missing in ip6tables, adding now"
                        add_v6firewall_rule
                fi

                sleep 60
        done
}


######################### MAIN #######################

start_firewall_service

