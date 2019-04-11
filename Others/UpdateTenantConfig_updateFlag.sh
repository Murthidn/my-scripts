#!/usr/bin/env bash

#This Script will enable falg if it's disabled in PreparedData, MatchStore and EntityTransform
#Looping Tenants
for tenants in $(jq '.TenantInfo | keys | .[]' file.json); do

    #Get Tenant Name
    tenantId=$(cat file.json | jq '.TenantInfo['$tenants'].tenantID')
    echo "Tenant ID: "$tenantId

        #Check 'create' flag is enabled or not in PreparedData
        isDisabledInPD=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.PreparedData.created')

        if [ $isDisabledInPD == "true" ]; then
	        echo "Flag already exists and enabled in PreparedData"

        elif [ $isDisabledInPD == "false" ]; then
	        echo "Flag is disabled in PreparedData, go ahead and enable the flag"
 		    jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json

        else
	        echo "Falg doesn't exist in PreparedData"
        fi

        #Check 'create' flag is enabled or not in MatchStore
        isDisabledInMS=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.MatchStore.created')

        if [ $isDisabledInMS == "true" ]; then
	        echo "Flag already exists and enabled in MatchStore"

        elif [ $isDisabledInMS == "false" ]; then
            echo "Flag is disabled in MatchStore, go ahead and enable the flag"
 		    jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json

        else
	        echo "Falg doesn't exist in MatchStore"
        fi

        #Check 'create' flag is enabled or not in EntityTransform
        isDisabledInET=$(cat file.json | jq '.TenantInfo['$tenants'].analytics.EntityTransform.created')

        if [ $isDisabledInET == "true" ]; then
	        echo "Flag already exists and enabled in EntityTransform"

        elif [ $isDisabledInET == "false" ]; then
             echo "Flag is disabled in EntityTransform, go ahead and enable the flag"
 		    jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' file.json > tmp.json && mv --force tmp.json file.json

        else
	        echo "Falg doesn't exist in EntityTransform"
        fi

done