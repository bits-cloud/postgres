#!/bin/bash

if [ $"ARCHIVE_MODE" = 'off' ] 
then
  echo "ARCHIVE_MODE is 'off'. Skipping Database dump"
  exit 0
fi

cd /

FILENAME="$(date +"%Y-%m-%d__%H:%M")__${POSTGRES_DB}.tar"

echo "-> CREATE DATABASE DUMP ${PG_BACKUP_DUMP}/${FILENAME}"
runuser --user postgres -- pg_dump -f "${PG_BACKUP_DUMP}/${FILENAME}" --format=t --dbname="${POSTGRES_DB}" --username=${POSTGRES_USER} --no-password

echo "-> DELETE OLD BACKUPS WITH STRATEGY: ${DUMP_STRATEGY}"
if [ "${DUMP_STRATEGY}" = "full" ]
then

  find "${PG_BACKUP_DUMP}" -mtime +365 -exec rm {} \;
  find "${PG_BACKUP_DUMP}" -mtime +30 ! -name "*01__00:00.sql" -exec rm {} \;
  find "${PG_BACKUP_DUMP}" -mtime +1 ! -name "*00:00.sql" -exec rm {} \;

elif [ "${DUMP_STRATEGY}" = "compact" ]
then  

  find "${PG_BACKUP_DUMP}" -mtime +7 -exec rm {} \;
  find "${PG_BACKUP_DUMP}" -type f -mmin +180 ! -name "*00:00.sql" -exec rm {} \;

elif [ "${DUMP_STRATEGY}" = "minimal" ] 
then

    find "${PG_BACKUP_DUMP}" -type f -mmin +180 -exec rm {} \;

fi