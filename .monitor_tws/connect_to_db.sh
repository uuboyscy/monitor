#!/bin/bash

put="$(cat /etc/hostname)"
sqlplus $(cat ./.secret/.userid)@${put: -1}sid/$(cat ./.secret/.passwd) 
