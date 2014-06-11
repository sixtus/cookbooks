#!/bin/bash

ip route add <%= node[:ipaddress] %>/32 dev eth0
ip route add default via <%= node[:ipaddress] %>
