#!/bin/ksh
#--------------------------------------------------------------------------------------------------
# Script Name   : unix_gcp_extrt.ksh
# Usage         : unix_gcp_extrt.ksh
#--------------------------------------------SOS--------------------------------------------------#
#==================================================================================================
# Description:
# This script will perform the following:
# Transfers the extracted data from unix to Google cloud's local processing location(VM instance)
  and uploads the data file into bucket.
#==================================================================================================
#Author: Venkata Rahul
#Date Created:  04/06/2022
#Modification History:
#
#  Date        Who          Description
#--------- ------------- --------------------------------------------------------------------------

###################################################################################################

export SCRIPT=`basename $0 |cut -f1 -d.`

#-------------------------------------------------------------------------------------------------#
#                       Error message for the invalid Usage inputs                                #
#-------------------------------------------------------------------------------------------------#
function usage
{
print ""
print "*** Invalid usage for running the script ${SCRIPT}! Expected usage format below."
print ""
print "      Expected usage         : ${SCRIPT} -f <filename>"
print "      Expected usage example : unix_gcp_extrt.ksh -f SPCLT_CNTR_SFDC_CNTCT_I.20220321.104529"
print "      Passed usage           : ${SCRIPT} -f $FILE_NM"
print ""
print "      Please correct the passed usage and resubmit the script for execution."
print ""
exit 1
}

#-------------------------------------------------------------------------------------------------#
#                            Setting Environment Variables                                        #
#-------------------------------------------------------------------------------------------------#
function set_env_vars
{
   echo "\nDefining environment variables."
   export DLS_TIMESTAMP=`date +%Y"%m""%d.%H"%M`
   export DLS_APPLOG=/shared/etl_apps/edw1/apps/log/$SCRIPT.$DLS_TIMESTAMP.log
   echo ${DLS_APPLOG} 
   . $DLS_HOME/scripts/edws0002.ksh
   
}

function set_opts
{
   while getopts :f: opts
   do
   case $opts in
     \?)  usage;;
      f)  export FILE_NM=$OPTARG
      *)  usage;;
   esac
   done
   if [[ $# -eq 0 ]]
 then
    usage
   fi
}

function data_transfer
{
   pwd=$(pwd)
   scp -r pbatch@10.93.69.56:/appl/edw/outgoing/rxcntrl_rpt/$FILE_NM ${pwd}
   gsutil cp $FILE_NM gs://cdp-dev-ingress/rxcntrl
   if [[$? !=0 ]]; then
       echo "Transfer of data for File $FILE_NM failed, check the LOG file"
       exit 1
   else
       echo "Transfer Success"
       echo "Transfered File:"
       find . -type f -print | grep '$FILE_NM'
       rm $FILE_NM
}


#------------------------------------------------------------------------------------------#
#                                    MAIN FLOW                                             #
#------------------------------------------------------------------------------------------#
optstr="`echo $@`"

set_opts $@

set_env_vars

data_transfer