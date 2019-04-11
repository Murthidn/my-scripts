#!/usr/bin/env bash

#This Script will create falg if doesn't exist in PreparedData, MatchStore and EntityTransform
#Looping Tenants
for tenants in $(jq '.TenantInfo | keys | .[]' file.json); do

    #Get Tenant Name
    tenantId=$(cat file.json | jq '.TenantInfo['$tenants'].tenantID')
    echo "Tenant ID: "$tenantId

        #Check 'create' flag exists or not in PreparedData
        isCreateInPD=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.PreparedData.created')

        if [ $isCreateInPD == "true" ]; then
	        echo "Flag already exists and enabled in PreparedData"

        elif [ $isCreateInPD == "false" ]; then
	        echo "Flag already exists and disabled in PreparedData"

        else
	        echo "Falg doesn't exist in PreparedData, go ahead and create new flag"
 		    jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json
        fi

        #Check 'create' flag exists or not in MatchStore
        isCreateInMS=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.MatchStore.created')

        if [ $isCreateInMS == "true" ]; then
	        echo "Flag already exists and enabled in MatchStore"

        elif [ $isCreateInMS == "false" ]; then
	        echo "Flag already exists and disabled in MatchStore"

        else
	        echo "Falg doesn't exist in MatchStore, go ahead and create new flag"
 		    jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json
        fi

        #Check 'create' flag exists or not in EntityTransform
        isCreateInET=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.EntityTransform.created')

        if [ $isCreateInET == "true" ]; then
	        echo "Flag already exists and enabled in EntityTransform"

        elif [ $isCreateInET == "false" ]; then
	        echo "Flag already exists and disabled in EntityTransform"

        else
	        echo "Falg doesn't exist in EntityTransform, go ahead and create new flag"
 		    jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json
        fi

done