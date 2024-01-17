#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "NVMeStorage: Installing daemon for nvmestorage"
  cp -vf /usr/bin/bc /tmpRoot/usr/bin/bc
  cp -vf /usr/sbin/nvmestorage.sh /tmpRoot/usr/sbin/nvmestorage.sh
  DEST="/tmpRoot/lib/systemd/system/nvmestorage.service"
  echo "[Unit]"                                    >${DEST}
  echo "Description=Enable M2 volume"             >>${DEST}
  echo "After=multi-user.target"                  >>${DEST}
  echo                                            >>${DEST}
  echo "[Service]"                                >>${DEST}
  echo "Type=oneshot"                             >>${DEST}
  echo "RemainAfterExit=true"                     >>${DEST}
  echo "ExecStart=/usr/sbin/nvmestorage.sh -ne"   >>${DEST}
  echo                                            >>${DEST}
  echo "[Install]"                                >>${DEST}
  echo "WantedBy=multi-user.target"               >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/nvmestorage.service /tmpRoot/lib/systemd/system/multi-user.target.wants/nvmestorage.service
fi
