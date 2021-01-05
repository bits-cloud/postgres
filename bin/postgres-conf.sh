#!/bin/bash

sed -i "s/#listen_addresses = .*/listen_addresses = '*'  	# what IP address(es) to listen on;/" "${PGDATA}/postgresql.conf"

echo "-> SETTING POSTGRES MEMORY PARAMETERS"
sed -i "s/shared_buffers = .*/shared_buffers = ${SHARED_BUFFERS}  # min 128kB/" "${PGDATA}/postgresql.conf"
sed -i "s/#effective_cache_size = .*/effective_cache_size = ${EFFECTIVE_CACHE_SIZE}/" "${PGDATA}/postgresql.conf"

echo "-> SETTING POSTGRES ARCHIVE PARAMETERS"
sed -i "s/#archive_mode = .*/archive_mode = '${ARCHIVE_MODE}'  # enables archiving; off, on, or always/" "${PGDATA}/postgresql.conf"
sed -i "s/#archive_command = .*/archive_command = '${ARCHIVE_COMMAND}'  # command to use to archive a logfile segment/" "${PGDATA}/postgresql.conf"
sed -i "s/#wal_level = .*/wal_level = ${WAL_LEVEL}  # minimal, replica, or logical/" "${PGDATA}/postgresql.conf"


echo "-> SETTING POSTGRES RECOVERY PARAMETERS"
sed -i "s/#restore_command = .*/restore_command = '${RESTORE_COMMAND}'  # command to use to restore an archived logfile segment/" "${PGDATA}/postgresql.conf"
