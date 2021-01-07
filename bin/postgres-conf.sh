#!/bin/bash

sed -i "s/.*listen_addresses = .*/listen_addresses = '*'  	# what IP address(es) to listen on;/" "${PGDATA}/postgresql.conf"

echo "-> SETTING POSTGRES MEMORY PARAMETERS"
sed -i "s/.*shared_buffers = .*/shared_buffers = ${SHARED_BUFFERS}  # min 128kB/" "${PGDATA}/postgresql.conf"
sed -i "s/.*effective_cache_size = .*/effective_cache_size = ${EFFECTIVE_CACHE_SIZE}/" "${PGDATA}/postgresql.conf"

echo "-> SETTING POSTGRES ARCHIVE PARAMETERS"
sed -i "s/.*archive_mode = .*/archive_mode = '${ARCHIVE_MODE}'  # enables archiving; off, on, or always/" "${PGDATA}/postgresql.conf"
sed -i "s/.*archive_command = .*/archive_command = '${ARCHIVE_COMMAND}'  # command to use to archive a logfile segment/" "${PGDATA}/postgresql.conf"
sed -i "s/.*wal_level = .*/wal_level = ${WAL_LEVEL}  # minimal, replica, or logical/" "${PGDATA}/postgresql.conf"


echo "-> SETTING POSTGRES RECOVERY PARAMETERS"
sed -i "s/.*restore_command = .*/restore_command = '${RESTORE_COMMAND}'  # command to use to restore an archived logfile segment/" "${PGDATA}/postgresql.conf"

echo "-> CHECKING FOR ZFS OPTIONS ZFS_OPTIONS: ${ZFS_OPTIONS}"
if [ "${ZFS_OPTIONS}" = 'on' ] || [ "${ZFS_OPTIONS}" = 'ON' ] 
then
  sed -i "s/.*wal_recycle = .*/wal_recycle = 'off'  # recycle WAL files/" "${PGDATA}/postgresql.conf"
  sed -i "s/.*wal_init_zero = .*/wal_init_zero = 'off'  # recycle WAL files/" "${PGDATA}/postgresql.conf"
else
  sed -i "s/.*wal_recycle = .*/wal_recycle = 'on'  # recycle WAL files/" "${PGDATA}/postgresql.conf"
  sed -i "s/.*wal_init_zero = .*/wal_init_zero = 'on'  # recycle WAL files/" "${PGDATA}/postgresql.conf"
fi