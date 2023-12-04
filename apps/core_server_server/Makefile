
bootstrap-auth:
	docker cp ./generated/tables-serverpod-auth.pgsql core_server_server-postgres-1:/docker-entrypoint-initdb.d/tables-serverpod-auth.pgsql && docker exec -u postgres core_server_server-postgres-1 psql core_server postgres -f /docker-entrypoint-initdb.d/tables-serverpod-auth.pgsql
bootstrap:
	docker cp ./generated/tables-serverpod.pgsql core_server_server-postgres-1:/docker-entrypoint-initdb.d/tables-serverpod.pgsql && docker exec -u postgres core_server_server-postgres-1 psql core_server postgres -f /docker-entrypoint-initdb.d/tables-serverpod.pgsql
bootstrap-tables:
	docker cp ./generated/tables.pgsql core_server_server-postgres-1:/docker-entrypoint-initdb.d/tables.pgsql && docker exec -u postgres core_server_server-postgres-1 psql core_server postgres -f /docker-entrypoint-initdb.d/tables.pgsql

gen:
	serverpod generate
detach:
	docker-compose up --build --detach

start:
	dart bin/main.dart