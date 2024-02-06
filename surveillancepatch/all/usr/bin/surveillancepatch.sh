#!/usr/bin/env bash

SSPATH="/var/packages/SurveillanceStation"

if [ -d "${SSPATH}" ]; then
    
    PATHROOT="${SSPATH}/target"
    PATHLIB="${PATHROOT}/lib"
    PATHSCRIPTS="${PATHROOT}/scripts"
    SPATCH="/usr/lib"

    /usr/syno/bin/synopkg stop SurveillanceStation
    sleep 20

    rm -f "${PATHLIB}/libssutils.so"
    cp -f "${SPATCH}/libssutils.so" "${PATHLIB}/libssutils.so"
    chown SurveillanceStation:SurveillanceStation "${PATHLIB}/libssutils.so"
    chmod 0644 "${PATHLIB}/libssutils.so"

    rm -f "${PATHSCRIPTS}/S82surveillance.sh"
    cp -f "${SPATCH}/S82surveillance.sh" "${PATHSCRIPTS}/S82surveillance.sh"
    chown SurveillanceStation:SurveillanceStation "${PATHSCRIPTS}/S82surveillance.sh"
    chmod 0755 "${PATHSCRIPTS}/S82surveillance.sh"

    rm -f "${PATHSCRIPTS}/license.sh"
    cp -f "${SPATCH}/license.sh" "${PATHSCRIPTS}/license.sh"
    chown SurveillanceStation:SurveillanceStation "${PATHSCRIPTS}/license.sh"
    chmod 0777 "${PATHSCRIPTS}/license.sh"

    echo -e "Surveillance Patch: Successfull!"

    sleep 5
    /usr/syno/bin/synopkg start SurveillanceStation

fi

exit 0