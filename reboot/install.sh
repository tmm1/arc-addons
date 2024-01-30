#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing addon reboottoarc - late"

  if [ ! -f /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db ]; then
    echo "copy esynoscheduler.db"
    mkdir -p /tmpRoot/usr/syno/etc/esynoscheduler
    cp -f /addons/esynoscheduler.db /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db
  fi
  echo "insert RebootToArpl task to esynoscheduler.db"
  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
  /tmpRoot/bin/sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
DELETE FROM task WHERE task_name LIKE 'RebootToLoader';
INSERT INTO task VALUES('RebootToArc', '', 'shutdown', '', 0, 0, 0, 0, '', 0, '/usr/sbin/loader-reboot.sh "config"', 'script', '{}', '', '', '{}', '{}');
EOF
fi