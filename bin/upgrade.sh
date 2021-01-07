#!/bin/bash

# load scripts
PGDATA_OLD="${PGDATA}_${PG_MAJOR_OLD}"

function dumpOldDatabase()
{
  echo "-> CREATING A DUMP OF THE OLD DATABASE"

  FILENAME="$(date +"%Y-%m-%d__%H:%M")__${POSTGRES_DB}__v${PG_MAJOR_OLD}-to-v${PG_MAJOR}.tar"

  runuser --user postgres -- "${PG_BIN_OLD}/pg_ctl" -D "${PGDATA}" -o "-c listen_addresses='' -p '5432'"  --wait --timeout="${DATABASE_CHECK_TIME}" --silent --log=/dev/null start

  runuser --user postgres -- "${PG_BIN_OLD}/pg_dump" -f "${PG_BACKUP_DUMP}/${FILENAME}" --format=t --create --clean --if-exists --dbname="${POSTGRES_DB}" --username=${POSTGRES_USER} --no-password

  runuser --user postgres -- "${PG_BIN_OLD}/pg_ctl" -D "${PGDATA}"  -m fast  --wait --timeout="${DATABASE_CHECK_TIME}" --silent stop
}


function upgrade()
{
  echo "MOVING DATA / DELETEING OLD BASEBACKUPS AND WALS"
  mv "${PGDATA}" "${PGDATA_OLD}"
  rm -rf "${PG_BACKUP_WAL}"/*
  rm -rf "${PG_BACKUP_BASEBACKUP}"
  
  echo "INIT A NEW DB WITH VERSION ${PG_MAJOR}"
  /usr/local/bin/init-db.sh
  /usr/local/bin/postgres-conf.sh

  echo "-> EXECUTING THE UPGRADE"

  # change directory to get write access for the log files
  cd /postgres

  runuser --user postgres -- pg_upgrade --old-bindir="${PG_BIN_OLD}" --new-bindir="${PG_BIN}" --old-datadir="${PGDATA_OLD}" --new-datadir="${PGDATA}" --user="${POSTGRES_USER}" --link

  echo "-> ANALYZING NEW CLUSTER"
  runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}" -o "-c listen_addresses='' -p '5432'"  --wait --timeout="${DATABASE_CHECK_TIME}" --silent --log=/dev/null start

  "${PG_BIN}/vacuumdb" --user="${POSTGRES_USER}" --all --analyze-in-stages

  runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}"  -m fast  --wait --timeout="${DATABASE_CHECK_TIME}" --silent stop

  echo "-> DELETING OLD CLUSTER"
  rm -rf "${PGDATA_OLD}" todo: uncomment
  find /postgres -maxdepth 1 -type f -exec rm {} \;

  cd /
}

dumpOldDatabase
upgrade
