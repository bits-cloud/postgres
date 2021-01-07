docker build ../. -t evokom/postgres:latest && \
docker run -it --rm \
-v "${PWD}/docker/postgres":/postgres \
-v "${PWD}/docker/backup":/backup \
-e POSTGRES_PASSWORD=secret \
-e POSTGRES_USER=user \
-e POSTGRES_DB=test-db \
-e DUMP_STRATEGY=minimal \
-e DUMP_TIME="* * * * *" \
-e BASEBACKUP_TIME="*/5 * * * *" \
-e SHARED_BUFFERS="256MB" \
-e EFFECTIVE_CACHE_SIZE="3GB" \
-p 5432:5432 \
--shm-size 256MB \  # set this so we can increase the shared buffers for postgres
--name postgres \
evokom/postgres:latest /bin/bash