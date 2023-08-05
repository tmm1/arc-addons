#!/usr/bin/env ash

  if [ "7" = "$(/bin/get_key_value /etc.defaults/VERSION majorversion)" ]; then
    DEST=/tmpRoot/lib/systemd/system/acpid.service
    echo "[Unit]"                               >${DEST}
    echo "Description=ACPI Daemon"             >>${DEST}
    echo "DefaultDependencies=no"              >>${DEST}
    echo "IgnoreOnIsolate=true"                >>${DEST}
    echo "After=multi-user.target"             >>${DEST}
    echo                                       >>${DEST}
    echo "[Service]"                           >>${DEST}
    echo "Restart=always"                      >>${DEST}
    echo "RestartSec=30"                       >>${DEST}
    echo "PIDFile=/var/run/acpid.pid"          >>${DEST}
    echo "ExecStart=/usr/sbin/acpid -f"        >>${DEST}
    echo                                       >>${DEST}
    echo "[X-Synology]"                        >>${DEST}
    echo "Author=Virtualization Team"          >>${DEST}

    mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
    ln -vsf /lib/systemd/system/acpid.service /tmpRoot/lib/systemd/system/multi-user.target.wants/acpid.service
  fi
fi