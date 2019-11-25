#!/bin/bash
set -u

######################################
#
# Show each js and its id
# The information includes 
# 	js name, date, status, id
#
######################################


filename='./.secret/tmp_js_output'
exec < $filename

# Count js
c=1

# Initial tmp_id_file
if [ -d "./.secret/tmp_id_file" ];
then
	rm ./.secret/tmp_id_file
fi

while read line
do
	# Print js and id
	printf "%-3s %-20s %-8s %-8s" $c. $(echo $line | awk -F'#' '{print $2}' | awk -F' ' '{print $1}') \
		$(echo $line | awk -F'#' '{print $2}' | awk -F' ' '{print $4}') \
		$(echo $line | awk -F'#' '{print $2}' | awk -F' ' '{print $3}')
	#echo $line | awk -F'; ' '{print $2}' | awk -F'{' '{print $2}' | awk -F'}' '{print $1}'
	echo $line | awk -F'{' '{print $NF}' | awk -F'}' '{print $1}'
	echo ""
	
	c=$(expr $c + 1)
done

