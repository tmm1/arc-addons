#!/usr/bin/env ash

if [ "${1}" = "early" ]; then
  /usr/bin/diskhibernation.py 2>/dev/null
elif [ "${1}" = "late" ]; then
  echo "Creating service to exec Diskhibernation"
  cp -vf /usr/bin/diskhibernation.py /tmpRoot/usr/bin/diskhibernation.py
  DEST="/tmpRoot/lib/systemd/system/diskhibernation.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Enable Diskhibernation"                                   >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=python3 /usr/bin/diskhibernation.py --install"              >>${DEST}
  echo "ExecStop=python3 /usr/bin/diskhibernation.py --install"               >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -p /tmpRoot/etc/systemd/system/multi-user.target.wants
  ln -sf /lib/systemd/system/diskhibernation.service /tmpRoot/lib/systemd/system/multi-user.target.wants/diskhibernation.service
fi