#!/bin/bash

if [ $"ARCHIVE_MODE" = 'off' ] 
then
  echo "ARCHIVE_MODE is 'off'. Skipping basebackup"
  exit 0
fi

cd /

OLD_BACKUP="${PG_BACKUP_BASEBACKUP}-old"
NEW_BACKUP="${PG_BACKUP_BASEBACKUP}-new"

# first delete the old files
rm -rf "${OLD_BACKUP}"
rm -rf "${NEW_BACKUP}"
rm -rf "${PGDATA}/backup_label.old" "${PGDATA}/backup_label"

echo "-> CREATEING BASEBACKUP"
runuser --user postgres -- pg_basebackup --username="${POSTGRES_USER}" --no-password --pgdata="${NEW_BACKUP}" --wal-method=stream # --format=t

if [ "$?" -gt 0 ] 
then
  echo "ERROR CREATING BASEBACKUP. STARTING AGAIN IN 120 SECONDS"
  sleep 120
  /usr/local/bin/create-basebackup.sh
  exit 1
fi

# second move default files to old and new to default
# this delete old files (costly operation)
# this should give a certain consistency to always have  the correct files at the default location
if [ -d "${PG_BACKUP_BASEBACKUP}" ]
then
  mv "${PG_BACKUP_BASEBACKUP}" "${OLD_BACKUP}"
fi
mv "${NEW_BACKUP}" "${PG_BACKUP_BASEBACKUP}"
rm -rf "${OLD_BACKUP}"

echo "-> BASEBACKUP CREATED"

echo "-> DELETE OLD WAL's"
# read the latest wal id from backup_label file
LATEST_BACKUP_WAL=$(head -1 ${PG_BACKUP_BASEBACKUP}/backup_label | awk '{ split($NF, wal, /)/); print wal[1]; }')

pg_archivecleanup "${PG_BACKUP_WAL}" "${LATEST_BACKUP_WAL}"
find "${PG_BACKUP_WAL}" -name "*.backup" -exec rm {} \; # delete all .backup files
