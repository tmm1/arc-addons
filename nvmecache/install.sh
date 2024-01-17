#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "NVMeCache: Installing daemon for nvmecache"
  cp -vf /usr/sbin/nvmecache.sh /tmpRoot/usr/sbin/nvmecache.sh
  DEST="/tmpRoot/lib/systemd/system/nvmecache.service"
  echo "[Unit]"                                    >${DEST}
  echo "Description=Enable M2 Cache"              >>${DEST}
  echo "After=multi-user.target"                  >>${DEST}
  echo                                            >>${DEST}
  echo "[Service]"                                >>${DEST}
  echo "Type=oneshot"                             >>${DEST}
  echo "RemainAfterExit=true"                     >>${DEST}
  echo "ExecStart=/usr/sbin/nvmecache.sh"         >>${DEST}
  echo                                            >>${DEST}
  echo "[Install]"                                >>${DEST}
  echo "WantedBy=multi-user.target"               >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/nvmecache.service /tmpRoot/lib/systemd/system/multi-user.target.wants/nvmecache.service
fi
