docker build ../. -t evokom/postgres:latest && \
docker run -it --rm \
-v "${PWD}/docker/postgres":/postgres \
-v "${PWD}/docker/backup":/backup \
-e POSTGRES_PASSWORD=secret \
-e POSTGRES_USER=user \
-e POSTGRES_DATABASE=test-db \
-e DUMP_STRATEGY=minimal \
-e DUMP_TIME="* * * * *" \
-e BASEBACKUP_TIME="*/5 * * * *" \
-p 5432:5432 \
--name postgres \
evokom/postgres:latest /bin/bash