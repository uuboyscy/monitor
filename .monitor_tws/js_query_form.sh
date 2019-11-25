#!/bin/bash
set -u
#set -x

###################################################
#
# Show certain job_stream information
#
# Include JS_NAME JOB_NAME FIRST_NAME SECOND_NAME
#	  SRC_OWNER SRC_NAME TGT_OWNER TGT_NAME
#	  DESCRIPTION JOB_SYS
#
# And save them in the file named "sqlplus_output"
#
##################################################

if [ -f "./.secret/sqlplus_output" ];
then
	rm ./.secret/sqlplus_output
fi

put="$(cat /etc/hostname)"
sqlplus $(cat ./.secret/.userid)@${put: -1}sid/$(cat ./.secret/.passwd) << EOF > ./.secret/sqlplus_output.tmp
SET LINESIZE 100;
SET PAGESIZE 30;
SELECT '+++' || CHR(10)
       || 'JS_NAME' || CHR(9) || CHR(9) || ':' || JS_NAME || CHR(10)
       || 'JOB_NAME' || CHR(9) || ':' || JOBNAME || CHR(10)
       || 'FIRST_NAME' || CHR(9) || ':' || FIRST_NAME || CHR(10)
       || 'SECOND_NAME' || CHR(9) || ':' || SECOND_NAME || CHR(10)
       || 'SRC_OWNER' || CHR(9) || ':' || SRC_OWNER || CHR(10)
       || 'SRC_NAME' || CHR(9) || ':' || SRC_NAME || CHR(10)
       || 'TGT_OWNER' || CHR(9) || ':' || TGT_OWNER || CHR(10)
       || 'TGT_NAME' || CHR(9) || ':' || TGT_NAME || CHR(10)
       || 'DESCRIPTION' || CHR(9) || ':' || FILE_DESCRIPTION || CHR(10)
       || 'JOB_SYS' || CHR(9) || CHR(9) || ':' || JOBSYS || CHR(10)
       || '++'
       INFORMATION
FROM (
    SELECT a.NUM, a.JOBNAME, a.JS_NAME, a.JOBSYS, a.FIRST_NAME, a.SECOND_NAME, a.FILE_DESCRIPTION
           , a.SRC_OWNER, a.SRC_NAME
           , b.NAME TGT_NAME, b.OWNER TGT_OWNER
    FROM (
        SELECT a.NUM, a.JOBNAME, a.JS_NAME, a.JOBSYS, a.FIRST_NAME, a.SECOND_NAME, a.FILE_DESCRIPTION
               , b.OWNER SRC_OWNER, b.NAME SRC_NAME
        FROM (
            SELECT NUM, JOBNAME, JOBSYS, FILE_DESCRIPTION, JS_NAME, FIRST_NAME, SECOND_NAME
            FROM ODS_SYSTEM.RD_JOBINFO
            WHERE JS_NAME='$1') a
        LEFT JOIN ODS_SYSTEM.RD_JOBSRCINFO b
        ON a.JOBNAME=b.JOBNAME) a
    LEFT JOIN ODS_SYSTEM.RD_JOBTGTINFO b
    ON a.JOBNAME=b.JOBNAME);
EXIT;
EOF

sed -n '/+++/,/++/p' ./.secret/sqlplus_output.tmp | sed -n '2,11'p >> ./.secret/sqlplus_output

if [ -f "./.secret/sqlplus_output.tmp" ];
then
	rm ./.secret/sqlplus_output.tmp
fi


cat ./.secret/sqlplus_output

