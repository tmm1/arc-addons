#!/usr/bin/env bash

SPPATH="/var/packages/SynologyPhotos"

if [ -d "${SPPATH}" ]; then
    /usr/syno/bin/synopkg stop SynologyPhotos
    sleep 10

    ./PatchELFSharp "/usr/lib/libsynosdk.so.7" "SYNOFSIsRemoteFS" "B8 00 00 00 00 C3"
    # support face and concept
    ./PatchELFSharp "/var/packages/SynologyPhotos/target/usr/lib/libsynophoto-plugin-platform.so" "_ZN9synophoto6plugin8platform20IsSupportedIENetworkEv" "B8 00 00 00 00 C3"
    # force to support concept
    ./PatchELFSharp "/var/packages/SynologyPhotos/target/usr/lib/libsynophoto-plugin-platform.so" "_ZN9synophoto6plugin8platform18IsSupportedConceptEv" "B8 01 00 00 00 C3"
    # force no Gpu
    ./PatchELFSharp "/var/packages/SynologyPhotos/target/usr/lib/libsynophoto-plugin-platform.so" "_ZN9synophoto6plugin8platform23IsSupportedIENetworkGpuEv" "B8 00 00 00 00 C3"

    sleep 5
    /usr/syno/bin/synopkg start SynologyPhotos
fi