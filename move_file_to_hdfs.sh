#!/bin/bash
set -u
#set -x


##################### CONFIGURATION ######################

SNAP=$(date  "%Y.%m.%d %H:%M:%S %a")

FILE_PATH_DMZ=$1
FILE_PATH_EMISAP="/tmp/tmp_file_dir/"
FILE_PATH_HADOOP="/tmp/tmp_file_dir/"
FILE_PATH_HDFS="/user/bdpadmin/testfiledir/"
FILE_NAME=$(echo $FILE_PATH_DMZ | awk -F'/' '{print $NF}')
LOG_PATH="/home/testuser/"
LOG_FILE_NAME="testfile.log"

EMIS_AP="172.123.123.123"
EMIS_AP_NAME="apuser"
EMIS_KEY_PATH="/home/testuser/.ssh/id_rsa"

HADOOP="172.123.123.123"
HADOOP_NAME="bdpadmin"
HADOOP_KEY_PATH="/home/apuser/ssh-tool/hdfs.pem"

HIVE_DB_NAME="ods_crl"
HIVE_TABLE_NAME=$(echo $FILE_NAME | awk -F'_2' '{print $1}')
HIVE_TABLE_COLUMNS_ARRAY=$(head $FILE_PATH_DMZ -n1 | awk -F',' '{for (i=1;$i!=$NF;i  )print $i " STRING,";print $NF ;print " STRING"}')
HIVE_CREATE_TABLE_SQL="hive -e \\\"CREATE EXTERNAL TABLE $HIVE_DB_NAME.$HIVE_TABLE_NAME ($HIVE_TABLE_COLUMNS_ARRAY) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';\\\""
HIVE_TABLE_PATH="/user/hive/warehouse/$HIVE_DB_NAME.db/$HIVE_TABLE_NAME/"

##########################################################


# Create log file
mkdir -p $LOG_PATH
touch $LOG_FILE_NAME

# Move file to EMIS_AP from DMZ, if fail -> exit
ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "mkdir -p $FILE_PATH_EMISAP"
scp -i $EMIS_KEY_PATH $FILE_PATH_DMZ $EMIS_AP_NAME@$EMIS_AP:$FILE_PATH_EMISAP$FILE_NAME
if [ $(ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ls -q $FILE_PATH_EMISAP | grep $FILE_NAME") = "$FILE_NAME" ];then
        echo "[SUCCE]" [$(date  "%Y.%m.%d %H:%M:%S %a")] "$FILE_NAME move to EMIS_AP from DMZ." >> $LOG_PATH$LOG_FILE_NAME
else
        echo "[ERROR]" [$(date  "%Y.%m.%d %H:%M:%S %a")] "$FILE_NAME not found in EMIS_AP." >> $LOG_PATH$LOG_FILE_NAME
        exit
fi

# Move file to HADOOP from EMIS_AP, if fail -> exit
ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP \
        "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP 'mkdir -p $FILE_PATH_HADOOP'
         scp -i $HADOOP_KEY_PATH $FILE_PATH_EMISAP$FILE_NAME $HADOOP_NAME@$HADOOP:$FILE_PATH_HADOOP$FILE_NAME"

if [ $(ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP 'ls -q $FILE_PATH_HADOOP | grep $FILE_NAME'") = "$FILE_NAME" ];then
        echo "$FILE_NAME uploaded to HADOOP"
        echo "Starting put file $FILE_NAME to HDFS"
        # Delete column name row then put the file to HDFS
        ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "rm $FILE_PATH_EMISAP$FILE_NAME
                                                      ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP '
                                                                sed -i \"1d\" $FILE_PATH_HADOOP$FILE_NAME
                                                                hadoop fs -mkdir $FILE_PATH_HDFS
                                                                hadoop fs -put $FILE_PATH_HADOOP$FILE_NAME $FILE_PATH_HDFS'"
        echo "Done"
        echo "[SUCCE]" [$(date  "%Y.%m.%d %H:%M:%S %a")] "$FILE_NAME move to HDFS from EMIS_AP." >> $LOG_PATH$LOG_FILE_NAME
else
        echo "Error"
        echo "[ERROR]" [$(date  "%Y.%m.%d %H:%M:%S %a")] "$FILE_NAME not found in HADOOP." >> $LOG_PATH$LOG_FILE_NAME
        exit
fi

# Create or insert into HIVE TABLE, if fail -> exit
# Check if DB exists
if [ $(ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP 'hadoop fs -ls /user/hive/warehouse | grep $HIVE_DB_NAME' | awk -F'/' '{print \$NF}'") = "$HIVE_DB_NAME.db" ];then
        echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Database" $HIVE_DB_NAME "exists." >> $LOG_PATH$LOG_FILE_NAME
        # Check if TABLE exists
        if [ $(ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP 'hadoop fs -ls /user/hive/warehouse/$HIVE_DB_NAME.db | grep $HIVE_TABLE_NAME' | awk -F'/' '{print \$NF}'") = "$HIVE_TABLE_NAME" ];then
                # Insert into
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Table" $HIVE_TABLE_NAME "exists." >> $LOG_PATH$LOG_FILE_NAME
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Insert data into" $HIVE_TABLE_NAME "." >> $LOG_PATH$LOG_FILE_NAME
                # INSERT INTO, that is, move file to table folder
                ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP \"hadoop fs -mv $FILE_PATH_HDFS$FILE_NAME $HIVE_TABLE_PATH\""
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Completed." >> $LOG_PATH$LOG_FILE_NAME
        else
                # if TABLE does not exist -> Create table
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Table" $HIVE_TABLE_NAME "does not exists, create table $HIVE_DB_NAME.$HIVE_TABLE_NAME ." >> $LOG_PATH$LOG_FILE_NAME
                #ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP \"hive -e '$HIVE_CREATE_TABLE_SQL'\""
                ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP \"$HIVE_CREATE_TABLE_SQL\""
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Table $HIVE_DB_NAME.$HIVE_TABLE_NAME created." >> $LOG_PATH$LOG_FILE_NAME
                # INSERT INTO, that is, move file to table folder
                ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP \"hadoop fs -mv $FILE_PATH_HDFS$FILE_NAME $HIVE_TABLE_PATH\""
                echo "[INFO] " [$(date  "%Y.%m.%d %H:%M:%S %a")] "Completed." >> $LOG_PATH$LOG_FILE_NAME
        fi
# If DB does not exist -> Create DB
else
        ssh -i $EMIS_KEY_PATH $EMIS_AP_NAME@$EMIS_AP "
                                                        ssh -i $HADOOP_KEY_PATH $HADOOP_NAME@$HADOOP \"
                                                        hive -e 'CREATE DATABASE IF NOT EXISTS $HIVE_DB_NAME;'\"
        "
fi
