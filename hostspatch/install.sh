#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  # Define the entries to be added
  ENTRIES=("127.0.0.1 checkip.synology.com" "::1 checkipv6.synology.com")

  # Loop over each entry
  for ENTRY in "${ENTRIES[@]}"
  do
      # Check if the entry is already in the file
      if grep -Fxq "$ENTRY" /tmpRoot/etc/hosts
      then
          echo "Entry $ENTRY already exists"
      else
          echo "Entry $ENTRY does not exist, adding now"
          echo "$ENTRY" >> /tmpRoot/etc/hosts
      fi
  done
fi