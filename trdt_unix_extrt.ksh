#!/bin/ksh
#--------------------------------------------------------------------------------------------------
# Script Name   : trdt_unix_extrt.ksh
# Usage         : trdt_unix_extrt.ksh
#--------------------------------------------SOS--------------------------------------------------#
#==================================================================================================
# Description:
# This script will perform the following:
# Extracts the data from Teradata based on the configurations specified and stores it in a specified
  location.
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
print "      Expected usage         : ${SCRIPT} -m <modulename>"
print "      Expected usage example : trdt_unix_extrt.ksh -m SPCLT_CNTR_SFDC_CNTCT_I"
print "      Passed usage           : ${SCRIPT} -m $MDULE_NM"
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
   while getopts :m: opts
   do
   case $opts in
     \?)  usage;;
      m)  export MDULE_NM=$OPTARG
      *)  usage;;
   esac
   done
   if [[ $# -eq 0 ]]
 then
    usage
   fi
}

function data_extract
{
   cd /appl/edw/scripts
   timestamp = $(date +"%Y%m%d.%H%M%S")
   edwt0525_extr.ksh -j MJ_NBR -m $MDULE_NM -f N
   if [[$? !=0 ]]; then
       echo "Extraction of data for Module $MDULE_NM failed, check the LOG file"
       exit 1
   else
       echo "Extraction Success"
       cd /appl/edw/outgoing/rxcntrl_rpt
       echo "Extracted File:"
       find . -type f -print | grep '$MDULE_NM'
       
}

############################################################################################

#------------------------------------------------------------------------------------------#
#                                    MAIN FLOW                                             #
#------------------------------------------------------------------------------------------#
optstr="`echo $@`"

set_opts $@

set_env_vars

data_extract