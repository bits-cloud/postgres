#!/bin/bash

RECOVERY_SIGNAL_FILE="${PGDATA}/recovery.signal"

if [ ! -f "${PG_BACKUP_BASEBACKUP}/PG_VERSION" ]
then
  echo "NO BASEBACKUP AVAILABLE..."
  echo ""
  echo "ABORTING..."
  echo ""

  exit 0
fi

if [ -f "${RECOVERY_SIGNAL_FILE}" ]
then
  echo "RECOVERY ALREADY IN PROGRESS... JUST TOOK TO LONG..."
  echo ""
  echo "ABORTING..."
  echo ""

  exit 0
fi

runuser --user postgres -- find "${PGDATA}/pg_wal" -maxdepth 1 -type f -exec cp -a {} "${PG_BACKUP_BASEBACKUP}/pg_wal" \;
rm -rf "${PGDATA}"
runuser --user postgres -- cp -a "${PG_BACKUP_BASEBACKUP}" "${PGDATA}"
runuser --user postgres -- touch "${RECOVERY_SIGNAL_FILE}"
