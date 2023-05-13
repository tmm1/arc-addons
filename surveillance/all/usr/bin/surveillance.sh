#!/usr/bin/env ash

PATH1="/var/packages/SurveillanceStation/target/lib/"
PATH2="/var/packages/SurveillanceStation/target/scripts"

if [ -f "${PATH1}/libssutils.so" ]; then
    /usr/syno/bin/synopkg stop SurveillanceStation
    sleep 5

    cp ${PATH1}/libssutils.so ${PATH1}/libssutils.so.bak
    rm -f ${PATH1}/libssutils.so
    wget https://github.com/AuxXxilium/Surveillance-Station/raw/main/lib/SurveillanceStation-x86_64/libssutils.so ${PATH1}/libssutils.so
    chown SurveillanceStation:SurveillanceStation ${PATH1}/libssutils.so
    chmod 0644 ${PATH1}/libssutils.so

    cp ${PATH2}/S82surveillance.sh ${PATH2}/S82surveillance.sh.bak
    rm -f ${PATH2}/S82surveillance.sh
    wget https://raw.githubusercontent.com/AuxXxilium/Surveillance-Station/main/lib/license/S82surveillance.sh ${PATH2}/S82surveillance.sh
    chown SurveillanceStation:SurveillanceStation ${PATH2}/S82surveillance.sh
    chmod 0755 ${PATH2}/S82surveillance.sh

    rm -f ${PATH2}/license.sh
    wget https://raw.githubusercontent.com/AuxXxilium/Surveillance-Station/main/lib/license/license.sh ${PATH2}/license.sh
    chown SurveillanceStation:SurveillanceStation ${PATH2}/license.sh
    chmod 0777 ${PATH2}/license.sh

    sleep 5
    /usr/syno/bin/synopkg start SurveillanceStation
fi