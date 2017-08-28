#!/bin/sh
#
Beerware="Beer-ware licensed by Mantas Smelevicius <mantas@mantas.lt>"
#/*
# * ----------------------------------------------------------------------------
# * "THE BEER-WARE LICENSE" (Revision 42):
# *  <mantas@mantas.lt>  wrote this file.  As long as you retain this notice you
# * can do whatever you want with this stuff. If we meet some day, and you think
# * this stuff is worth it, you can buy me a beer in return.  Mantas Smelevicius
# * ----------------------------------------------------------------------------
# */
#
##########################################################################
#
#  Program: check_mount.sh
#
#  Parameters:
#              $1   -  FS to check --MANDATORY--
#              $2   -  Mount type  [ ceph | nfs3 | nfs4 | cifs | jfs2 | procfs | ext3 | ext4... ]  --OPTIONAL-- (CEPH by default)
#
#  Output:
#              3    -  Error:    No FS passed on parameter $1.
#              2    -  CRITICAL: FS not OK, the FS specified is not mounted by $2.
#              1    -  WARNING:  FS not OK, the FS specified is mounted several times (it might not be a problem).
#              0    -  OK:       FS OK, the FS specified has an instance mounted under $2 mount type.
#
#  Description:
#
#    Shell Script for Nagios, checks if the FS passed on $1 is mounted under Mount Type $2. If no parameter passed on $2
#    CEPH type is assumed by default. This script do not check fstab or /etc/filesystem or other tab entries, as it is
#    designed to consume as little CPU time as possible and to be used in different OS types.
#
#    It is a simple script, but it detects mounts of practically any type of FS, and multiple instances mounted of the same FS.
#
# Versions       Date        Programmer, Modification
# ------------   ----------  ----------------------------------------------------
#  Version=1.00 # 07/06/2017  Mantas Smelevicius. Initial version
  Version=1.01 # 07/06/2017  Mantas Smelevicius. Fixed typos
#
#########################################################################
#set -x

# Constants

 NAGIOS_ERROR=3
 NAGIOS_CRIT=2
 NAGIOS_WARN=1
 NAGIOS_OK=0


# Usage

if [ $# -lt 1 ]
  then
    cat << EOF
check_mount.sh v$Version - $Beerware

  ERROR - No FS passed under parameter \$1

     USE:
            check_mount.sh [ \$1 - Filesystem ]  | optional: [ \$2 - Type (CEPH by default)]

     Reports:
            OK - \$1 mounted under \$2.
	    CRITICAL - \$1 not mounted under \$2.
	    WARNING - \$1 is mounted several times! (number of times mounted)

     Examples:
            check_mount.sh /developer/logs       <-- check CEPH mount of /developer/logs
            check_mount.sh /db2 ext3             <-- check EXT3 mount of /db2

EOF
    RC=$NAGIOS_ERROR
    exit $RC
fi
FS=$1


# Main

MOUNT=$2
if [ -z "$MOUNT" ]
  then
    MOUNT="ceph"         # if $2 not specified, assume CEPH by default
fi

MOUNTED=`mount | grep $MOUNT | grep $FS | wc -l | tr -s " "`            # execute the command to check the mount...
if [ $MOUNTED -eq 0 ]; then
    MSG="CRITICAL - $FS not mounted under $MOUNT."
    RC=$NAGIOS_CRIT
  elif [ $MOUNTED -eq 1 ]; then
    MSG="OK - $FS mounted under $MOUNT."
    RC=$NAGIOS_OK
  else
    MSG="WARNING - $FS is mounted several times! ($MOUNTED)"
    RC=$NAGIOS_WARN
fi

echo $MSG
exit $RC

# End
