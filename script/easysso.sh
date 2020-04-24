#!/bin/bash

if [ $(echo $1 | wc -c) -le 3 ] || [ $(echo $2 | wc -c) -le 3 ]
then
	echo App name or location either missing or app name is shorter than permitted. Please specify a unique name that is at least 3 characters.
	echo syntax: $0 app-name location-name
else
	#setting up the variable; no need to edit any other lines after this section
	appName=$1
	rgName=$(echo $appName)rg
	location=$2
	storage=$(echo $appName |sed s/-//g)storage
	appUrl=https://$appName.azurewebsites.net
	curl -Lfs $appUrl
	if [ "$?" -ne 6 ]
	then
		echo web app $appUrl already exist.
		echo please provide a unique name for the web app.
		exit
	fi

	webappName=$(echo $appName)-demo
	webappUrl=https://$(echo $webappName).azurewebsites.net
	curl -Lfs $webappUrl
	if [ "$?" -ne 6 ]
	then
		echo web app $webappUrl already exists.
	        echo please provide a unique name for the web app.
		exit
	fi

	replyUrl1=$(echo $webappUrl)/success
	replyUrl2=$(echo $appUrl)/.auth/login/aad/callback

	#starting execution of steps
	echo checking connectivity to azure subscription...
	if [ $(az account show -o tsv --query id 2>&1 |wc -c) -eq 40 ]
	then
		echo -e please follow the instructions below to connect your azure subscription...
		echo	
		az login -o tsv
	fi

	#gathering information to set up the environment
	echo querying tenant id...
	tenantId=$(az account show -o tsv --query tenantId)
	echo querying subscription id...
	subId=$(az account show -o tsv --query id)
	echo acquiring access token...
	token=$(az account get-access-token -o tsv --query accessToken)
	echo creating manifest for resource access...
	echo '[{
	"resourceAppId": "00000003-0000-0000-c000-000000000000",
	"resourceAccess": [
	{
	"additionalProperties": null,
	"id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
	"type": "Scope"
	}
	]
	}]' >manifest.json
	echo creating and acquiring service principal id...
	appId=$(az ad app create --display-name $appName --homepage $appUrl --identifier-uris $appUrl --reply-urls $replyUrl1 $replyUrl2 --required-resource-accesses @manifest.json -o tsv --query appId)

	#creating resources
	echo creating resource group $rgName...
	az group create -n $rgName -l $location
	echo creating B1 app service plan for demo web app...
	az appservice plan create -g $rgName -n $(echo $webappName)-plan
	echo creating demo web app...
	az webapp create -g $rgName -p $(echo $webappName)-plan -n $webappName
	echo deploying code to demo web app...
	az webapp deployment source config-zip -g $rgName -n $webappName --src ../release/App.zip
	echo creating storage account $storage...
	az storage account create -n $storage -g $rgName -l $location --sku Standard_LRS --kind StorageV2
	echo creating function app...
	az functionapp create --consumption-plan-location $location --name $appName --os-type Windows --resource-group $rgName --runtime dotnet --storage-account $storage --functions-version 2

	echo updating authentication settings...
	az webapp auth update -g $rgName -n $appName --enabled true --action LoginWithAzureActiveDirectory --aad-allowed-token-audiences $appUrl --aad-client-id $appId --aad-token-issuer-url https://sts.windows.net/$tenantId

	echo updating additional login parameters...
	#this is needed to get token in JWT format; jsander's blog on access tokens
	curl -X PUT --header "Authorization: Bearer $token" https://management.azure.com/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.Web/sites/$appName/config/authsettings?api-version=2018-02-01 -d "{\"properties\":{\"additionalLoginParams\":[\"resource=$appId\"]}}" -H "Content-Type: application/json"

	echo
	echo
	echo all set! Please use the following URLs for to initiate Azure AD login and logout flows...
	echo URLs will also be saved in $(echo $appName)-urls.txt
	echo =========================================================================================
	echo login URL: |tee -a $(echo $appName)-urls.txt
	echo ========== |tee -a $(echo $appName)-urls.txt
	loginUrl=$(echo https://login.microsoftonline.com/$(echo $tenantId)/oauth2/authorize?response_type=id_token\&redirect_uri=$(echo $replyUrl1)\&client_id=$(echo $appId)\&scope=openid+profile+email\&response_mode=form_post\&resource=\&nonce=fb57942e3d0f43698c83e4b923b68470_20200406130225)
	echo $loginUrl |tee -a $(echo $appName)-urls.txt
	echo |tee -a $(echo $appName)-urls.txt

	echo logout URLs: |tee -a $(echo $appName)-urls.txt
	echo =========== |tee -a $(echo $appName)-urls.txt
	logoutUrl=$(echo https://login.microsoftonline.com/$(echo $tenantId)/oauth2/v2.0/logout)
	echo $logoutUrl |tee -a $(echo $appName)-urls.txt
	echo https://login.microsoftonline.com/common/oauth2/v2.0/logout |tee -a $(echo $appName)-urls.txt
fi
