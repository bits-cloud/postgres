#!/bin/bash

function PG_PASSWORD()
{
  if [ -z "$POSTGRES_PASSWORD" ] 
  then
    echo "-> POSTGRES_PASSWORD needs to have a value!"
    echo "-> VALIDATION ABORTED"
    exit 1
  fi

  if [ "${#POSTGRES_PASSWORD}" -ge 100 ] 
  then
    echo "-> WARNING: The supplied POSTGRES_PASSWORD is 100+ characters."
    echo "-> This will not work if used via PGPASSWORD with \"psql\"."
    echo "-> https://www.postgresql.org/message-id/flat/E1Rqxp2-0004Qt-PL%40wrigleys.postgresql.org (BUG #6412)"
    echo "-> https://github.com/docker-library/postgres/issues/507"
    echo "-> VALIDATION ABORTED"
    exit 2
  fi

  echo "-> POSTGRES_PASSWORD OK"
}

function PG_USER()
{
  if [ -z "$POSTGRES_USER" ] 
  then
    echo "-> POSTGRES_USER needs to have a value!"
    echo "-> VALIDATION ABORTED"
    exit 3
  fi

  echo "-> POSTGRES_USER OK"
}

function PG_DATABASE()
{
  if [ -z "$POSTGRES_DATABASE" ] 
  then
    echo "-> POSTGRES_DATABASE needs to have a value!"
    echo "-> VALIDATION ABORTED"
    exit 4
  fi

  echo "-> POSTGRES_DATABASE OK"
}

function ARCHIVE_MODE()
{
  if [ "$ARCHIVE_MODE" = "on" ]
  then
    
    if [ -z "$ARCHIVE_COMMAND" ] 
    then
        echo "-> ARCHIVE_COMMAND CAN NOT BE ''"
        exit 5
    fi
    
    if [ -z "$RESTORE_COMMAND" ] 
    then
        echo "-> RESTORE_COMMAND CAN NOT BE ''"
        exit 6
    fi

    if [ -z "$WAL_LEVEL" ] 
    then
        echo "-> WAL_LEVEL CAN NOT BE ''"
        exit 7
    fi

    if [ "$WAL_LEVEL" != 'replica' ] && [ "$WAL_LEVEL" != 'logical' ]    
    then
        echo "-> WAL_LEVEL NEEDS TO HAVE VALUE 'replica' OR 'logical'"
        exit 8
    fi

  fi

  echo "-> ARCHIVE_MODE OK"
}

PG_PASSWORD
PG_USER
PG_DATABASE
ARCHIVE_MODE

exit 0