#!/usr/bin/env bash

SPPATH="/var/packages/SynologyPhotos"

if [ -d "${SPPATH}" ]; then

/usr/syno/bin/synopkg stop SynologyPhotos
sleep 10

/usr/sbin/PatchELFSharp "/usr/lib/libsynosdk.so.7" "SYNOFSIsRemoteFS" "B8 00 00 00 00 C3"
/usr/sbin/PatchELFSharp "/var/packages/SynologyPhotos/target/usr/lib/libsynophoto-plugin-platform.so" "_ZN9synophoto6plugin8platform20IsSupportedIENetworkEv" "B8 00 00 00 00 C3"

sleep 5
/usr/syno/bin/synopkg start SynologyPhotos

fi