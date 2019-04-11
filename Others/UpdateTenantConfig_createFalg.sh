#!/usr/bin/env bash

#This Script will create falg if doesn't exist in PreparedData, MatchStore and EntityTransform

echo "Enter input file name: "
read inputFile

#Looping Tenants
for tenants in $(jq '.TenantInfo | keys | .[]' $inputFile); do

    #Get Tenant Name
    tenantId=$(cat $inputFile | jq '.TenantInfo['$tenants'].tenantID')
    echo "Tenant ID: "$tenantId

        #Check 'create' flag exists or not in PreparedData
        isCreateInPD=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.PreparedData.created')

        if [ $isCreateInPD == "true" ]; then
	        echo "Flag already exists and enabled in PreparedData"

        elif [ $isCreateInPD == "false" ]; then
	        echo "Flag already exists and disabled in PreparedData"

        else
	        echo "Falg doesn't exist in PreparedData, going ahead and creating the flag"
 		    jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
        fi

        #Check 'create' flag exists or not in MatchStore
        isCreateInMS=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.MatchStore.created')

        if [ $isCreateInMS == "true" ]; then
	        echo "Flag already exists and enabled in MatchStore"

        elif [ $isCreateInMS == "false" ]; then
	        echo "Flag already exists and disabled in MatchStore"

        else
	        echo "Falg doesn't exist in MatchStore, going ahead and creating the flag"
 		    jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
        fi

        #Check 'create' flag exists or not in EntityTransform
        isCreateInET=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.EntityTransform.created')

        if [ $isCreateInET == "true" ]; then
	        echo "Flag already exists and enabled in EntityTransform"

        elif [ $isCreateInET == "false" ]; then
	        echo "Flag already exists and disabled in EntityTransform"

        else
	        echo "Falg doesn't exist in EntityTransform, going ahead and creating the flag"
 		    jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
        fi

done