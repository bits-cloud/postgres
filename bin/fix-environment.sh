#!/bin/bash

echo "FIXING /etc/environment FOR CRONJOBS"
echo "export PGDATA=${PGDATA}" >> /etc/environment
echo "export PG_BIN=${PG_BIN}" >> /etc/environment
echo "export PG_BACKUP_WAL=${PG_BACKUP_WAL}" >> /etc/environment
echo "export PG_BACKUP_BASEBACKUP=${PG_BACKUP_BASEBACKUP}" >> /etc/environment
echo "export PG_BACKUP_DUMP=${PG_BACKUP_DUMP}" >> /etc/environment
echo "export POSTGRES_USER=${POSTGRES_USER}" >> /etc/environment
echo "export POSTGRES_DB=${POSTGRES_DB}" >> /etc/environment
echo "export ARCHIVE_MODE=${ARCHIVE_MODE}" >> /etc/environment
echo "export DUMP_STRATEGY=${DUMP_STRATEGY}" >> /etc/environment

echo "ADDING CRONJOBS"
mkdir -p /var/spool/cron/crontabs
echo "${DUMP_TIME} . /etc/environment && /usr/local/bin/create-dump.sh" >> /var/spool/cron/crontabs/root
echo "${BASEBACKUP_TIME} . /etc/environment && /usr/local/bin/create-basebackup.sh" >> /var/spool/cron/crontabs/root
