RG=teams-cors-proxy

lint:
	az bicep build --file main.bicep

deploy:
	az group create --resource-group $(RG) --location japaneast
	az deployment group create \
		--resource-group $(RG) \
		--template-file main.bicep

clean:
	az group delete --resource-group $(RG) --yes
