#!/usr/bin/env ash

scriptver="23.7.2"
script=SurveillancePatch
repo="AuxXxilium/arc-addons"
SSPATH="/var/packages/SurveillanceStation"

if [ -d "${SSPATH}" ]; then
    
    PATHROOT="${SSPATH}/target"
    PATHLIB="${PATHROOT}/lib"
    SPATCH="/usr/lib"

    /usr/syno/bin/synopkg stop SurveillanceStation
    sleep 15

    #touch "${PATHROOT}/off.conf"
    #chown SurveillanceStation:SurveillanceStation "${PATHROOT}/off.conf"

    cp -f ${PATHLIB}/libssutils.so ${PATHLIB}/libssutils.so.bak
    rm -f ${PATHLIB}/libssutils.so
    cp -f ${SPATCH}/libssutils.so ${PATHLIB}/libssutils.so
    chown SurveillanceStation:SurveillanceStation ${PATHLIB}/libssutils.so
    chmod 0644 ${PATHLIB}/libssutils.so

    echo -e "Surveillance Patch: Successfull!"

    rm -f "${PATHROOT}/off.conf"

    sleep 5
    /usr/syno/bin/synopkg start SurveillanceStation

    systemctl enable surveillancepatchrecall.timer
    systemctl start surveillancepatchrecall.timer

fi