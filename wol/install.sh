#!/usr/bin/env ash

if [ "${1}" = "jrExit" ]; then
  /usr/sbin/ethtool -s eth0 wol g 2>/dev/null
elif [ "${1}" = "late" ]; then
  echo "WOL: Creating service to exec ethtool"
  cp -vf /usr/bin/ethtool /tmpRoot/usr/bin/ethtool
  DEST="/tmpRoot/lib/systemd/system/ethtool.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=ARC force WoL on eth0"                                    >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/bin/ethtool -s eth0 wol g"                             >>${DEST}
  echo "ExecStop=/usr/bin/ethtool -s eth0 wol g"                              >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/ethtool.service /tmpRoot/lib/systemd/system/multi-user.target.wants/ethtool.service
fi