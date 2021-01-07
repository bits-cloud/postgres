FROM ubuntu:focal

ENV RELEASE="focal" \
  PG_MAJOR=12 \
  PG_MAJOR_OLD=11 \
  PGDATA="/postgres/data" \
  \
  PG_BACKUP_WAL="/backup/wal" \
  PG_BACKUP_BASEBACKUP="/backup/basebackup" \
  PG_BACKUP_DUMP="/backup/dump" \
  PG_BACKUP_DUMP_RESTORE="/backup/restore" \
  \
  POSTGRES_USER= \
  POSTGRES_PASSWORD= \
  POSTGRES_DB= \
  POSTGRES_HOST_AUTH_METHOD="md5" \
  \
  # the docker default size of /dev/shm is 64MB
  SHARED_BUFFERS="64MB" \
  EFFECTIVE_CACHE_SIZE="2GB" \
  ZFS_OPTIONS='off' \
  \
  ARCHIVE_MODE="on" \
  WAL_LEVEL="replica" \
  DUMP_STRATEGY="full" \
  DATABASE_CHECK_TIME="45" \
  \
  ARCHIVE_COMMAND="test ! -f \/backup\/wal\/%f \&\& cp \%p \/backup\/wal\/%f" \
  RESTORE_COMMAND="cp \/backup\/wal\/%f %p" \
  \
  DUMP_TIME="0 * * * *" \
  BASEBACKUP_TIME="0 0 * * *"

ENV   PG_BIN="/usr/lib/postgresql/${PG_MAJOR}/bin" \
  PG_BIN_OLD="/usr/lib/postgresql/${PG_MAJOR_OLD}/bin"

ENV  LANG="en_US.utf8" \
  LC_ALL="en_US.UTF-8" \
  \
  PATH="$PATH:${PG_BIN}:/usr/sbin" 


# Setup POSTGRESQL
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update; \
  # packages to add apt repositories + locale
  apt-get install -y --no-install-recommends wget curl ca-certificates gnupg locales; \ 
  # runtime packages
  apt-get install -y --no-install-recommends nano supervisor busybox-static; \
  \
  # add postgresql repository
  echo "deb http://apt.postgresql.org/pub/repos/apt ${RELEASE}-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - ; \
  apt-get update; \
  \
  # postgres PG_MAJOR
  apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR}"; \
  # postgre PG_MAJOR_OLD
  apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR_OLD}"; \
  \
  # clean postgres home 
  rm -r /var/lib/postgresql/*; \
  rm -r /etc/postgresql/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

# change postgres id's
RUN set -eux; \
  usermod -u 1000 postgres; \
  groupmod -g 1000 postgres; \
  for i in `find / -user 101`; do chown 1000 $i; done; \
  for i in `find / -group 102`; do chgrp 1000 $i; done; \
  mkdir -p /var/lib/postgresql; \
  chown -R 1000:1000 /var/lib/postgresql; 

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; 
RUN echo "PATH=\"${PATH}\"" > /etc/environment; 

COPY supervisord.conf /etc/

COPY bin/* /usr/local/bin/
RUN chmod 777 /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/startup.sh"]

STOPSIGNAL SIGINT
EXPOSE 5432
VOLUME /postgres
VOLUME /backup

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]