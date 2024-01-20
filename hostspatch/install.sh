#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  # Define the entries to be added
  ENTRIES=("127.0.0.1 checkip.synology.com" "::1 checkipv6.synology.com")

  # Loop over each entry
  for ENTRY in "${ENTRIES[@]}"
  do
    if [ -f /etc/hosts ]; then
        # Check if the entry is already in the file
        if grep -Fxq "$ENTRY" /etc/hosts; then
            echo "Entry $ENTRY already exists"
        else
            echo "Entry $ENTRY does not exist, adding now"
            echo "$ENTRY" >> /etc/hosts
        fi
    fi
    if [ -f /tmpRoot/etc/hosts ]; then
        if grep -Fxq "$ENTRY" /tmpRoot/etc/hosts; then
            echo "Entry $ENTRY already exists"
        else
            echo "Entry $ENTRY does not exist, adding now"
            echo "$ENTRY" >> /tmpRoot/etc/hosts
        fi
    fi
  done
fi

if [ "${1}" = "late" ]; then
  echo "Creating service to exec Hostspatch"
  cp -vf /usr/sbin/hostspatch.sh /tmpRoot/usr/sbin/hostspatch.sh
  DEST="/tmpRoot/lib/systemd/system/hostspatch.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Enable CPU Info"                                          >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/sbin/hostspatch.sh"                                    >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/hostspatch.service /tmpRoot/lib/systemd/system/multi-user.target.wants/hostspatch.service
fi