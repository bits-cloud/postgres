#!/bin/bash

/usr/bin/pg_isready --username="${POSTGRES_USER}" --dbname="${POSTGRES_DB}" --host=127.0.0.1 --timeout=1 &> /dev/null

exit $?