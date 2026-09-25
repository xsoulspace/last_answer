gen-migrations:
	serverpod create-migration
apply-migrations:
	dart run bin/main.dart --role maintenance --apply-migrations
repair-migrations:
	serverpod create-repair-migration && dart run bin/main.dart --apply-repair-migration

recreate:
	docker-compose down -v && make detach

gen:
	serverpod generate

detach:
	docker-compose up --build --detach

start:
	dart bin/main.dart