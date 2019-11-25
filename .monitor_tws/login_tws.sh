#!/bin/bash
set -u

conman -username $(cat ./.secret/.tws_userid) -password $(cat ./.secret/.tws_passwd)
