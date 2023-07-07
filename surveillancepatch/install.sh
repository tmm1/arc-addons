#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Creating service to exec Surveillance Patch"
  cp -vf /usr/sbin/surveillancepatch.sh /tmpRoot/usr/sbin/surveillancepatch.sh
  cp -vf /usr/lib/libssutils.so /tmpRoot/usr/lib/libssutils.so
  chmod 755 /tmpRoot/usr/sbin/surveillancepatch.sh

  DEST="/tmpRoot/lib/systemd/system/surveillancepatch.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Surveillance Patch"                                       >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/sbin/surveillancepatch.sh"                             >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -p /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -sf /lib/systemd/system/surveillancepatch.service /tmpRoot/lib/systemd/system/multi-user.target.wants/surveillancepatch.service

  DEST="/tmpRoot/lib/systemd/system/surveillancepatchrecall.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Surveillance Patch Recall"                                >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/var/packages/SurveillanceStation/target/bin/ssctl start"   >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -p /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -sf /lib/systemd/system/surveillancepatchrecall.service /tmpRoot/lib/systemd/system/multi-user.target.wants/surveillancepatchrecall.service

  DEST="/tmpRoot/lib/systemd/system/surveillancepatchrecall.timer"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Surveillance Patch Recall Timer"                          >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Timer]"                                                              >>${DEST}
  echo "OnBoot=10"                                                            >>${DEST}
  echo "OnCalendar=*:0/60"                                                    >>${DEST}
  echo "Persistent=true"                                                      >>${DEST}
  echo "Unit=surveillancepatchrecall.service"                                 >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=timers.target"                                               >>${DEST}
  mkdir -p /tmpRoot/lib/systemd/system/timers.target.wants
  ln -sf /lib/systemd/system/surveillancepatchrecall.timer /tmpRoot/lib/systemd/system/timers.target.wants/surveillancepatchrecall.timer
fi
