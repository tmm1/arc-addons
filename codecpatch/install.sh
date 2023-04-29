#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing addon synocodec patch"
  cp -v /usr/bin/codecpatch.sh /tmpRoot/usr/bin/codecpatch.sh
  cp -v /usr/lib/systemd/system/codecpatch.service /tmpRoot/usr/lib/systemd/system/codecpatch.service
  # /lib -> /usr/lib; /etc/systemd/system/multi-user.target.wants/* -> /usr/lib/systemd/system/multi-user.target.wants/*
  mkdir -vp /tmpRoot/usr/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/codecpatch.service /tmpRoot/usr/lib/systemd/system/multi-user.target.wants/codecpatch.service
fi