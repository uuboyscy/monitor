#!/bin/bash
set -u
#set -x

#################################################################
#
# Sorting job_stream_id, job_detail in files 
# 
# Step1. Log in and qurey js_id which are abnormal
#        Put these information in a temporary file tmp_js_output
#
# Step2. Read tmp_js_output to extract each id of js
#        And save them in tmp_id_file
#
# Step3. Read tmp_id_file to extract id of js
#        Save detail in tmp_js_detail
#        Includ the steps in which the ERROR or STUCK occur
#
##################################################################


############## Log in TWS #########################

# The shell variable is used to show full name of js
export MAESTRO_OUTPUT_STYLE="LONG"

# These may be used in the future
day_yesterday=$(date -d yesterday +"%d")
month_yesterday=$(date -d yesterday +"%m")
year_yesterday=$(date -d yesterday +"%Y")


#echo "y" | conman -username ap****** -password Qa******** 'ss  @ODS_@' | grep $(month_yesterday)/ | grep -E "(ABEND|STUCK|ERROR)"

# Save abnormal js to tmp_js_output
#echo "y" | conman -username ap****** -password Qa******** 'ss  @ODS_@;showid' | grep -E "(ABEND|STUCK|ERROR)" > ./.secret/tmp_js_output
#echo "y" | conman -username $(cat ./.secret/.tws_userid) -password $(cat ./.secret/.tws_passwd) 'ss  @ODS_@;showid' | grep -E "(ABEND|STUCK|ERROR)" > ./.secret/tmp_js_output

#ssh to tpebnkmdmap01p
ssh $(cat ./.secret/.tws_userid)@tpebnkmdmap01p 'source ~/.bash_profile;clear;echo "y" | conman "ss  FODSETL01#@ODS@;showid" | grep -E "(ABEND|STUCK|ERROR)"' | sed -n '4,$p' > ./.secret/tmp_js_output

####################################################


############ Save id to tmp_id_file ################

# Initial tmp_id_file
if [ -f "./.secret/tmp_id_file" ];
then
        rm ./.secret/tmp_id_file
fi

# Read each row in ./tmp_js_output 
# and save each job whit job_id in ./tmp_js_output
filename='./.secret/tmp_js_output'
exec < $filename

while read line
do
        # Save id to tmp_id_file
        #echo "sj" $(echo $line | awk -F'; ' '{print $2}' | awk -F'{' '{print $2}' | awk -F'}' '{print $1}') ";schedid" >> ./.secret/tmp_id_file
        #echo "sj FODSETL01#$(echo $line | awk -F' ' '{print $2}' | awk -F'#' '{print $2}')" >> ./.secret/tmp_id_file
        echo "sj FODSETL01#$(echo $line | awk -F'{' '{print $NF}' | awk -F'}' '{print $1}');schedid" >> ./.secret/tmp_id_file
done

####################################################


######## Save job detail to tmp_js_detail ##########

# Initial tmp_js_detail
if [ -f "./.secret/tmp_js_detail" ];
then
        rm ./.secret/tmp_js_detail
fi

# Save js detail to tmp_js_detail
#filename='./.secret/tmp_id_file'
#exec < $filename

#o=1

#while read line
#do
#	echo $line
#	sleep 2s
#	echo "++$o++" >> ./.secret/tmp_js_detail
#	ssh $(cat ./.secret/.tws_userid)@tpebnkmdmap01p "source ~/.bash_profile;echo 'y' | conman '$line' > .tmp_js_detail;cat .tmp_js_detail" >> ./.secret/tmp_js_detail
#	echo "+$o+" >> ./.secret/tmp_js_detail
#	echo "" >> ./.secret/tmp_js_detail
#
#	o=$(expr $o + 1)
#done

### latest version
ssh $(cat ./.secret/.tws_userid)@tpebnkmdmap01p "source ~/.bash_profile;conman -username $(cat ./.secret/.tws_userid) -password $(cat ./.secret/.tws_passwd)" << EOF < ./.secret/tmp_id_file > test_EOF
EOF
echo "%abcdefg112233" >> test_EOF

# Save js detail to tmp_js_detail
filename='./.secret/tmp_id_file'
exec < $filename

o=1

while read line
do
        echo $line "executing..."
        #sleep 1s
        echo "++$o++" >> ./.secret/tmp_js_detail 
        echo $line >> ./.secret/tmp_js_detail
        sed -n "/%${line}/,/%/p" ./test_EOF >> ./.secret/tmp_js_detail
        echo "+$o+" >> ./.secret/tmp_js_detail
        echo "" >> ./.secret/tmp_js_detail

        o=$(expr $o + 1)
done

####################################################


######### Execute js_query_form_all.sh ## ##########

sleep 1s

sh ./js_query_form_all.sh

####################################################
