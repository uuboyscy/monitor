#!/bin/bash
set -u
#set -x

echo "======================="
echo "     Setup Oracle "
echo "======================="
echo "Enter your OracleDB ID >"
read a
echo "Enter your OracleDB password >"
read b

echo ""
echo "======================="
echo "       Setup TWS "
echo "======================="
echo "Enter your TWS ID >"
read c
echo "Enter your TWS password >"
read d

echo ""
echo "Setting..."
echo "$a" > .monitor_tws/.secret/.userid
echo "$b" > .monitor_tws/.secret/.passwd
echo "$c" > .monitor_tws/.secret/.tws_userid
echo "$d" > .monitor_tws/.secret/.tws_passwd
sleep 1s
echo "Done."
echo ""
