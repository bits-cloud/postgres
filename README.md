# evokom/Postgres

The Repository can be found [here](https://github.com/evokom/postgres)

This is a postgres docker image, that is built to keep your data safe.
This image will have two versions of postgres installed, to allow an upgrade between Postgres Versions.
The purpose make upgrading / restoreing a failed database as easy as possible.
This image will reduce the time spent to restore failed databases due to issues with shared Storage or crashed Kubernetes Clusters.

_You should set [SHARED_BUFFERS](#variables) and [EFFECTIVE_CACHE_SIZE](#variables) to your needs. You can get more information in the repository under /dev/docker-compose.yaml or /dev/run.sh_

### Upgrading

just install a new postgres image.
if within the /postgres volume is a directory with the older version name, the following steps will be done:

- postgres will execute a pg_dump
- postgres will attempt to upgrade to the new version.
- the old version will be deleted if successful

### backups

These steps will only be executed, if the ENV-VAR "ARCHIVE_MODE" is 'on'

#### basebackup

- the WAL will be archived in the /backup/wal directory (will contain the wals since the last basebackup)
- the basebackup will be saved in the /backup/basebackup (will be created every day)

on startup, the container will check if the old postgres-database is corrupted.
if it is, the following steps will be done:

- postgres will attempt to restore the database with a pg_basebackup + the archived WAL's

if this should fail, you can copy the latest dump into the /init directory to restore the database from a dump

#### dumps

every hour a database dump will be created.
Dumps that will be stored:

> DUMP_STRATEGY: full
>
> - every first day of the Month at 00:00 (for 1 year)
> - the first backup of every day (for 30 days)
> - The last 24 hours

> DUMP_STRATEGY: compact
>
> - the first backup of every day (for 7 days)
> - The last 3 hours

> DUMP_STRATEGY: minimal
>
> - The last 3 hours

##### restoring from dumps

you can move a dump with the format tar to /backup/restore to restore the database from a dump.
this can also be used to restore from another database.
the dump this image creates is created with the following parameters:

```
pg_dump --format=t --create --clean --if-exists
```

### Variables

**CRONJOBS**

> - **DUMP_TIME**: The time, when a database dump is created. default is every hour.  
>   _default: "0 \* \* \* \*"_
> - **BASEBACKUP_TIME**: The time, when a basebackup of the database is created. default is every day.  
>   _default: "0 0 \* \* \*"_

**DATABASE**

> - **POSTGRES_USER**: The Postgresql user
> - **POSTGRES_PASSWORD**: The user password
> - **POSTGRES_DB**: The default database name
> - **POSTGRES_HOST_AUTH_METHOD**: the authentication method for external connections.  
>   _default: 'md5'_

> - **DUMP_STRATEGY**: "full", "compact" or "minimal
>   see [dumps](#dumps) for a description of the strategies
> - **DATABASE_CHECK_TIME**: time in seconds to wait, before the scripts determine the database to be defect.  
>   This value should not be to low or to high, to guarantee the database could try to repair itself, before the restore-from-basebackup will be executed.  
>   _default: 45_

> ---

**CONFIG**

_BASE_

> - **SHARED_BUFFERS**: https://postgresqlco.nf/doc/en/param/shared_buffers/  
>   _default: 64MB - the default shared-memory for docker-containers_
> - **EFFECTIVE_CACHE_SIZE**: https://postgresqlco.nf/doc/en/param/effective_cache_size/  
>   _default: 2GB_

_ARCHIVING_

> - **ARCHIVE_MODE**: https://postgresqlco.nf/doc/en/param/archive_mode/  
>   _default: on_  
>   _this images uses uses archive_command instead of the recommended pg_receivewal to keep switch archiving on / off simple_

_ZFS_OPTIONS_

> - **ZFS_OPTIONS**: if ENV Variable is set to 'on', it will set **wal_recycle** and **wal_init_zero** to off, to improve zfs performance
