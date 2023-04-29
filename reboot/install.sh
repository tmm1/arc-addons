#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
echo "Insert RebootToArc Task"
sqlite3 /tmpRoot/usr/syno/etc/esynoscheduler/esynoscheduler.db <<EOF
INSERT INTO task VALUES('RebootToArpl', '', 'shutdown', '', 0, 0, 0, 0, '', 0, '/usr/bin/arpl-reboot.sh "config"', 'script', '{}', '', '', '{}', '{}');
EOF
fi