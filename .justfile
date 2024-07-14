set windows-shell := ["cmd.exe", "/C"]

# first recipe is the default - list all recipes
@help:
    just -l

@build_app:
    docker build rates/ -t cfptestregistry007.azurecr.io/cfp_app:latest

@build_db:
    docker build db/ -t cfptestregistry007.azurecr.io/cfp_db:latest
	
@compose:
	docker-compose up -d
	
@down:
	docker-compose down
	
[windows]
@run_cloud:
	run.bat
	terraform apply tfplan
	
[unix]
@run_cloud:
	./run.sh
	terraform apply tfplan