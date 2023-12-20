#!/bin/bash

CONTAINER_NAME="postgres-salud-tfe"
POSTGRES_PASSWORD="password"
SQL_FILES=("build.sql" "tables.sql" "data.sql" "triggers.sql" "views.sql")

docker pull postgres

docker run --name $CONTAINER_NAME -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p 5432:5432 -d postgres

for file in "${SQL_FILES[@]}"
do
  docker cp ./$file $CONTAINER_NAME:/docker-entrypoint-initdb.d/
done

sleep 5
docker restart $CONTAINER_NAME
docker exec -it $CONTAINER_NAME bash
