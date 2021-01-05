#!/bin/bash

mkdir -p "${PG_BACKUP_BASEBACKUP}" "${PG_BACKUP_DUMP}" "${PG_BACKUP_WAL}" "${PG_BACKUP_DUMP_RESTORE}"
chown -R postgres:postgres /postgres /backup "${PG_BACKUP_BASEBACKUP}" "${PG_BACKUP_DUMP}" "${PG_BACKUP_WAL}" "${PG_BACKUP_DUMP_RESTORE}"

function validate()
{
  echo "VALIDATING ENVIRONMENT VARIABLES ..."

  /usr/local/bin/validate.sh

  local RESULT="$?"

  # everything valid?
  if [ "${RESULT}" -ne 0 ] 
  then
    echo "VALIDATION FAILED, EXIT CODE ${RESULT}"
    exit "${RESULT}"
  fi

  echo "VALIDATION COMPLETED!"
  echo "================================================"
  echo
}

function environment_setup()
{
  echo "FIXING /etc/environment FOR CRONJOBS"
  echo "export PGDATA=${PGDATA}" >> /etc/environment
  echo "export PG_BIN=${PG_BIN}" >> /etc/environment
  echo "export PG_BACKUP_WAL=${PG_BACKUP_WAL}" >> /etc/environment
  echo "export PG_BACKUP_BASEBACKUP=${PG_BACKUP_BASEBACKUP}" >> /etc/environment
  echo "export PG_BACKUP_DUMP=${PG_BACKUP_DUMP}" >> /etc/environment
  echo "export POSTGRES_USER=${POSTGRES_USER}" >> /etc/environment
  echo "export POSTGRES_DATABASE=${POSTGRES_DATABASE}" >> /etc/environment
  echo "export ARCHIVE_MODE=${ARCHIVE_MODE}" >> /etc/environment
  echo "export DUMP_STRATEGY=${DUMP_STRATEGY}" >> /etc/environment

  echo "ADDING CRONJOBS"
  mkdir -p /var/spool/cron/crontabs
  echo "${DUMP_TIME} . /etc/environment && /usr/local/bin/create-dump.sh" >> /var/spool/cron/crontabs/root
  echo "${BASEBACKUP_TIME} . /etc/environment && /usr/local/bin/create-basebackup.sh" >> /var/spool/cron/crontabs/root
}

function postgres_setup()
{
  # create database if it does not exist 
  # -> PG_VERSION is always in the database directory
  if ! [ -f "${PGDATA}/PG_VERSION" ]
  then
    echo "INITIALIZING DATABASE"
    /usr/local/bin/init-db.sh
  else
    echo "DATABASE ALREADY INITIALIZED..."
  fi

  echo ""

  # edit postgresql.conf
  echo "FIXING postgresql.conf"
  /usr/local/bin/postgres-conf.sh

  echo "================================================"
  echo
}

function upgrade()
{
  if [ "$(cat ${PGDATA}/PG_VERSION)" = "${PG_MAJOR_OLD}" ] 
  then
    echo "UPGRADING FROM VERSION ${PG_MAJOR_OLD} TO VERSION ${PG_MAJOR}"
    /usr/local/bin/upgrade.sh
  else
    echo "DATABASE ALREADY ON THE LATEST VERSION..."
  fi

  echo "================================================"
  echo
}

function restore()
{
  runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}" -o "-c listen_addresses='' -p '5432'" -w start

  if [ "$?" -gt 0 ] 
  then
    echo "DATABASE HAS ERRORS THAT CAN NOT BE FIXED WITHOUT A BACKUP! RESTORING FROM BASEBACKUP..."
    /usr/local/bin/restore-from-basebackup.sh
  else
    echo "DATABASE IS OK"
    runuser --user postgres -- "${PG_BIN}/pg_ctl" -D "${PGDATA}" -m fast -w stop
  fi

  /usr/local/bin/restore-from-restore-folder.sh

  echo "================================================"
  echo
}

validate
environment_setup
postgres_setup
upgrade
restore

# start the server
exec $@