#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for CPU Info"
  cp -v /usr/bin/cpuinfo.sh /tmpRoot/usr/bin/cpuinfo.sh
  cp -v /usr/lib/systemd/system/cpuinfo.service /tmpRoot/usr/lib/systemd/system/cpuinfo.service
  # /lib -> /usr/lib; /etc/systemd/system/multi-user.target.wants/* -> /usr/lib/systemd/system/multi-user.target.wants/*
  mkdir -vp /tmpRoot/usr/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/cpuinfo.service /tmpRoot/usr/lib/systemd/system/multi-user.target.wants/cpuinfo.service
fi