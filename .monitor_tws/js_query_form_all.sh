#!/bin/bash
set -u
#set -x

########################################################
#
# Show all job_stream information from oracle
#
# Include JS_NAME JOB_NAME FIRST_NAME SECOND_NAME
#         SRC_OWNER SRC_NAME TGT_OWNER TGT_NAME
#         DESCRIPTION JOB_SYS
#
# And save them in the file named "sqlplus_output_all"
#
#######################################################

if [ -f "./.secret/sqlplus_output_all" ];
then
	rm ./.secret/sqlplus_output_all
fi

# Count js
c=1

for j in $(cat ./.secret/tmp_js_output | awk -F'#' '{print $2}' | awk '{print $1}')
do
	echo "++$c++" >> ./.secret/sqlplus_output_all
	sh js_query_form.sh $j >> ./.secret/sqlplus_output_all
	echo "+$c+" >> ./.secret/sqlplus_output_all
	echo "" >> ./.secret/sqlplus_output_all

	c=$(expr $c + 1)
done


