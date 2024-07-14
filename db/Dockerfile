FROM --platform=linux/amd64 postgres:13.5

# Copy the database rates.sql to the container
COPY src/rates.sql /docker-entrypoint-initdb.d/

