#!/bin/bash
DATE=`date +%F_%H-%M-%S`
UUIDFILE=./xen-uuids.txt
BACKUPPATH=/mnt/hdd
while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`
    SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT_${VMUUID}_$DATE"`
    xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPUUID
    xe vm-export vm=${SNAPUUID} filename="$BACKUPPATH/${VMNAME}_$DATE.xva" compress=false
    xe vm-uninstall uuid=$SNAPUUID force=true
done < $UUIDFILE
find ${BACKUPPATH} -name "*.xva" -type f -mtime +10 -delete