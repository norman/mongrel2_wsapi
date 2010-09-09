#!/bin/bash
killall mongrel2
m2sh init -db config.sqlite
m2sh load -db config.sqlite --config sample_config.py
rm sample_config.pyc
mkdir run
mkdir log
mkdir tmp
echo -e "\nNow trying to launch mongrel2 with sudo\n"
sudo m2sh start -db config.sqlite -host '(.+)'
echo -e "\nMongrel2 started. Now you can run the Lua app by simply doing:"
echo -e "\n\tlua sample_app.lua"
