#!/bin/bash
set -u
#set -x

######################################################################
#
# Usage:
#
# 	[JS OVERVIEW]
# 	 After js shown
#	 Press 1 to get data information from DB 
# 	 Press 2 to get abnormal job-stream and job status  
#	 Press 3 to get forestage information of abnormal JS 
#	 Press 4 to get holding JS forestage information 
#	 Press 0 to reload
#	 Press q to quit
#
#		[1 : DB : Select js number shown in the head of each row]
#		 Press 1 ~ n for getting the n_th js information
#		   (The number n is up to query result)
#		 Press r to return to the last step
#		 Press q to quit
#
#		[2 : TWS : Select js number]
#		 Press 1 ~ n for getting single js information
#		   (Include the step where job occur obstacle)
#		 Press r to return to the last step
#		 Press q to quit
#
#		[3 : TWS & CSV & DB : Select js number]
#		 ## Expect to do :
#		 #### 1. Forestage keyperson
#		 #### 2. File name
#		 #### 3. Last execute date and time
#		 Under construction...
#
#		[4 : TWS & CSV & DB : Select js number]
#		 ## Expect to do :
#		 #### 1. Forestage keyperson
#		 #### 2. File name
#		 #### 3. Last execute date and time
#		 Under construction...
#
######################################################################


######## Initiate all tmp file #########

echo "Loading data..."
sleep 2s
cd .monitor_tws
sh init.sh
#sleep 2s

js_count=$(wc -l ./.secret/tmp_js_output | awk '{print $1}')
echo $js_count

########################################


############ Main function #############

clear

OVERVIEW_OPTION="0"

while [ "$OVERVIEW_OPTION" != "q" ]
do
	# Show Job Stream menu
	echo ""
	echo "====================== JOB STREAM MENU ======================"
	echo ""
	sh show.sh
	echo "============================================================="
	
	echo ""
	echo "[1] Press 1 to get data information from DB"
	echo "[2] Press 2 to get abnormal job-stream and job status"
	echo "[3] Press 3 to get forestage information of abnormal JS"
	echo "[4] Press 4 to get holding JS forestage information"
	echo "[0] Press 0 to re-load"
	echo "[q] Press q to quit"
	echo -n ">>> "
	
	# For overview of all job stream
	read OVERVIEW_OPTION
	if [ "x$(echo $OVERVIEW_OPTION)" = "x1" ];
	then
		#echo "You enter $OVERVIEW_OPTION"
		DB_OPTION="0"
		while [ "$DB_OPTION" != "r" ]
		do
			echo ""
			echo "[Information to each js from DB]"
			echo "[1~$js_count] Choose JOB_STREAM number"
			echo "[0] Or enter 0 to show menu"
			echo "[r] Enter r to return"
			echo "[q] Press q to quit"
			echo -n ">>> "
			
			# Show information to JS from DB
			# Join RD_JOBINFO, RD_JOBSRCINFO, RD_JOBTGTINGO
			read DB_OPTION
			if [ "x$(echo $DB_OPTION)" != "xr" ];
			then
				echo ""
				echo "========================================="
				sed -n "/++${DB_OPTION}++/,/+${DB_OPTION}+/p" ./.secret/sqlplus_output_all | sed -n '2,11'p
				echo "========================================="
			fi

			# Re-show the Job Stream menu
			if [ "x$(echo $DB_OPTION)" = "x0" ];
			then
				clear
				echo "====================== JOB STREAM MENU ======================"
				echo ""
				sh show.sh
				echo "============================================================="
			fi

			# Quit the process
			if [ "x$(echo $DB_OPTION)" = "xq" ];
			then
				clear
				DB_OPTION="r"
				OVERVIEW_OPTION="q"
			fi
		done
	elif [ "x$(echo $OVERVIEW_OPTION)" = "x2" ]
	then
		#echo "You enter $OVERVIEW_OPTION"
		TWS_JS_OPTION="0"
		while [ "$TWS_JS_OPTION" != "r" ]
		do
			echo ""
			echo "[Job information]"
			echo "[1~$js_count] Choose JOB_STREAM number"
			echo "[0] Or enter 0 to show menu"
			echo "[r] Enter r to return"
			echo "[q] Press q to quit"
			echo -n ">>> "

			# Show the form for single job
			read TWS_JS_OPTION
			if [ "x$(echo $TWS_JS_OPTION)" != "xr" ];
			then
				echo ""
				echo "================================================================================================================"
				#echo "show each step in which the job occur obstacle"
				sed -n "/++${TWS_JS_OPTION}++/,/+${TWS_JS_OPTION}+/p" .secret/tmp_js_detail | sed '1,3d' | sed '$d'
				echo "================================================================================================================"
			fi
			
			# Re-show the Job Stream menu
			if [ "x$(echo $TWS_JS_OPTION)" = "x0" ];
                        then
                                clear
				echo "====================== JOB STREAM MENU ======================"
				echo ""
				sh show.sh
				echo "============================================================="
                        fi

			# Quit the process
			if [ "x$(echo $TWS_JS_OPTION)" = "xq" ];
			then
				clear
				TWS_JS_OPTION="r"
				OVERVIEW_OPTION="q"
			fi
		done
	elif [ "x$(echo $OVERVIEW_OPTION)" = "x3" ]
	then
		JS_FORESTAGE_OPTION="0"
		while [ "$JS_FORESTAGE_OPTION" != "r" ]
		do
			echo ""
			echo "[JS forestage information]"
			echo "[1~$js_count] Choose JOB_STREAM number"
			echo "[0] Or enter 0 to show menu"
			echo "[r] Enter r to return"
			echo "[q] Press q to quit"
			echo -n ">>> "

			read JS_FORESTAGE_OPTION

			# Show the form for single JS forestage information
			if [ "x$(echo $JS_FORESTAGE_OPTION)" != "xr" ];
			then
				TMP_JS_NAME=$(head ./.secret/tmp_js_output -n$JS_FORESTAGE_OPTION | tail -n1 | awk -F'#' '{print $2}' | awk -F' ' '{print $1}')
				echo ""
				#echo "show each step in which the job occur obstacle"
				#echo "$(JS_FORESTAGE_OPTION)"
				cd forestage_information/
				#forestage_information/show_forestage_info.py
				python show_forestage_info.py $TMP_JS_NAME
				cd ../
			fi
			
			# Re-show the Job Stream menu
			if [ "x$(echo $JS_FORESTAGE_OPTION)" = "x0" ];
                        then
                                clear
				echo "====================== JOB STREAM MENU ======================"
				echo ""
				sh show.sh
				echo "============================================================="
                        fi

			# Quit the process
			if [ "x$(echo $JS_FORESTAGE_OPTION)" = "xq" ];
			then
				clear
				JS_FORESTAGE_OPTION="r"
				OVERVIEW_OPTION="q"
			fi
		done
	elif [ "x$(echo $OVERVIEW_OPTION)" = "x4" ]
	then
		echo "Coming soon..."

	elif [ "x$(echo $OVERVIEW_OPTION)" = "x0" ]
	then
		clear
		echo "Loading data..."
		sleep 1s
		sh init.sh

		js_count=$(wc -l ./.secret/tmp_js_output | awk '{print $1}')
		echo $js_count
		clear		
	fi
done


########################################

echo "Bye!"
