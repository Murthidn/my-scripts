#!/usr/bin/env bash
#Get Jar version, base path and environment name
versionNumber=$1
basePath=$2
envName=$3

#Set Environment Type (Engg/CPS/PROD)
if echo "$envName" | grep -q "engg"; then
        setEnvName="ENGG"
        echo $setEnvName
elif echo "$envName" | grep -q "cps"; then
        setEnvName="CPS"
        echo $setEnvName
else
        setEnvName="PROD"
        echo $setEnvName
fi

#Install JQ by default
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
chmod +x ./jq && \
cp jq /usr/bin

#Get Tenants
curl -XPOST http://rdp-rest:8085/dataplatform/api/configurationservice/get?pretty -d '{ "params": { "query": { "filters": { "typesCriterion": [ "tenantserviceconfig" ] } }, "fields": { }, "options": { "totalRecords": 100 } } }' | jq '.' > tenant_list.txt

if grep -q "\"totalRecords\": 0" tenant_list.txt; then
echo "No tenants found in the system"
else
mkdir $basePath/AutoReports/AppReports
mkdir $basePath/AutoReports/AppReports/output

tenants=$(jq --raw-output '.response.configObjects[] | .id' tenant_list.txt)
tenants=$(sed "s| |;|g" <<< $tenants)
element_tenant=(${tenants//;/ })

#Check if build is QA and select only RDW Tenant if it has otherwise select all tenants
selectedTenant=$(grep -c "rdw" tenant_list.txt)
if echo "$envName" | grep -q "engg" && [ $selectedTenant -gt 0 ]; then
    echo "rdw" >> AppTenants.txt
else
  for j in "${!element_tenant[@]}"
  do
   echo ${element_tenant[j]} >> AppTenants.txt

  done
fi
fi

#loop through Tenants present in AppTenants.txt
for oneTenant in $(<AppTenants.txt)
do

#Get Entity Types of that Tenant
curl -X POST \
  -H "Content-Type:application/json" \
  -H "x-rdp-version:8.1" \
  -H "x-rdp-clientId:rdpclient" \
  -H "x-rdp-tenantId:${oneTenant}" \
  -H "x-rdp-ownershipData:Nike" \
  -H "x-rdp-userId:mary.jane@riversand.com" \
  -H "x-rdp-userName:Maryj" \
  -H "x-rdp-firstName:Mary" \
  -H "x-rdp-lastName:Jane" \
  -H "x-rdp-userEmail:mary.jane@riversand.com" \
  -H "x-rdp-userRoles:["admin"]" \
  http://rdp-rest:8085/${oneTenant}/api/entitymodelservice/get?pretty -d '{
  "params": {
    "query": {
      "domain": "thing",
      "filters": {
        "typesCriterion": [
        "entityType"
        ]
      }
    }
  }
}' | jq '.' > $basePath/AutoReports/AppReports/${oneTenant}_rawEntityTypes.txt

#Copy mail template to folder
cp $basePath/AutoReports/App_mailConfig_Template.json $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json

#Extract Entity Tyes
entityTpes=$(jq --raw-output '.response.entityModels[] | .name' $basePath/AutoReports/AppReports/${oneTenant}_rawEntityTypes.txt)
entityTpes=$(sed "s| |,|g" <<< $entityTpes)
echo $entityTpes > $basePath/AutoReports/AppReports/${oneTenant}_entityTypes.json

#Change Mail Configuration
sed -i -e "s|@@TENANT_ID@@|${oneTenant}|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json

if [ $setEnvName == "ENGG" ]; then
sed -i -e "s|@@RCPT@@|"rdpreportsengg@riversand.com\",\"engqa@riversand.com"|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json

elif [ $setEnvName == "CPS" ]; then
sed -i -e "s|@@RCPT@@|"rdpreportscps@riversand.com"|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json

else
sed -i -e "s|@@RCPT@@|"rdpreports@riversand.com"|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName - "PROD"|g" $basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json
fi

#Copy script template to the folder, change the parameters according to each Tenants and prepare scipt
cp $basePath/AutoReports/AppReport_Template.txt $basePath/AutoReports/AppReports/ApplicationReportTmp.txt

mkdir $basePath/AutoReports/AppReports/output/${oneTenant}_AppReport

sed -i -e "s|@@TENANT_ID@@|${oneTenant}|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt
sed -i -e "s|@@QUERY_PATH@@|$basePath/AutoReports/AppReports/${oneTenant}_entityTypes.json|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt
sed -i -e "s|@@OUTPUT@@|$basePath/AutoReports/AppReports/output/${oneTenant}_AppReport|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt
sed -i -e "s|@@JAR_PATH@@|$basePath|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt
sed -i -e "s|@@VERSION_NUMBER@@|$versionNumber|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt
sed  "s|@@MAIL_CONFIG@@|$basePath/AutoReports/AppReports/${oneTenant}_mailConfig.json|g" $basePath/AutoReports/AppReports/ApplicationReportTmp.txt >> $basePath/AutoReports/AppReports/ApplicationReport.sh

echo -e "\n" >> $basePath/AutoReports/AppReports/ApplicationReport.sh

chmod +x $basePath/AutoReports/AppReports/ApplicationReport.sh

done