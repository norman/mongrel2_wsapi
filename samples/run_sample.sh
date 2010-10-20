#!/bin/bash
killall mongrel2
m2sh load -config sample_config.conf
mkdir run
mkdir log
mkdir tmp
echo -e "\nNow trying to launch mongrel2 with sudo\n"
sudo m2sh start -host '(.+)'
echo -e "\nMongrel2 started. Now you can run the Lua app by simply doing:"
echo -e "\n\tlua sample_app.lua"
