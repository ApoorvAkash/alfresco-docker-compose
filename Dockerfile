FROM postgres:12.1
COPY multiple-postgresql-database.sh /docker-entrypoint-initdb.d/

