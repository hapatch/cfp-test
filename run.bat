docker build rates/ -t cfptestregistry007.azurecr.io/cfp_app:latest
docker build db/ -t cfptestregistry007.azurecr.io/cfp_db:latest
terraform init
terraform apply -target=azurerm_container_registry.registry
az acr login --name cfptestregistry007
docker push cfptestregistry007.azurecr.io/cfp_app:latest
docker push cfptestregistry007.azurecr.io/cfp_db:latest
terraform plan -out=tfplan