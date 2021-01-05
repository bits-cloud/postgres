#!/bin/bash

if [ "$(ls -1 ${PG_BACKUP_DUMP_RESTORE} | wc -l)" -gt 1 ] 
then
  echo "-> ${PG_BACKUP_DUMP_RESTORE} CONTAINS MORE THAN 1 FILE! ONLY 0 OR 1 FILES ALLOWED!"
  exit 1
fi

if [ "$(ls -1 ${PG_BACKUP_DUMP_RESTORE} | wc -l)" = 0 ] 
then
  echo "-> NO DUMP TO RESTORE..."
  exit 0
fi

echo "RESTORING DATABASE WITH DATA FROM ${PG_BACKUP_DUMP_RESTORE}"
runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}" -o "-c listen_addresses='' -p '5432'" -w start

# start with a clean database
runuser --user postgres -- /usr/bin/dropdb --if-exists --username="${POSTGRES_USER}" --no-password "${POSTGRES_DATABASE}"
runuser --user postgres -- /usr/bin/createdb --owner="${POSTGRES_USER}" --user="${POSTGRES_USER}" --no-password "${POSTGRES_DATABASE}"

runuser --user postgres -- find "${PG_BACKUP_DUMP_RESTORE}" -type f -name "*.tar" -exec "${PG_BIN}/pg_restore" --create --clean --if-exists --dbname="${POSTGRES_DATABASE}" --username="${POSTGRES_USER}" --no-password "{}" \;
rm -rf "${PG_BACKUP_DUMP_RESTORE}"/*

runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}" -m fast -w stop
