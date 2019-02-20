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

mkdir $basePath/AutoReports/LagReports
mkdir $basePath/AutoReports/LagReports/output

#Copy all mail templates and system configs to folder
cp $basePath/AutoReports/mailConfig.json $basePath/AutoReports/LagReports/mailConfig.json
cp $basePath/AutoReports/alertMailConfig.json $basePath/AutoReports/LagReports/alertMailConfig.json
cp $basePath/AutoReports/warningMailConfig.json $basePath/AutoReports/LagReports/warningMailConfig.json

cp $basePath/AutoReports/systemReportConfig.json $basePath/AutoReports/LagReports/systemReportConfig.json
cp $basePath/AutoReports/systemReport.txt $basePath/AutoReports/LagReports/systemReport.txt

#Move directly to folder and change mail configs according to Environments
cd $basePath/AutoReports/LagReports/

if [ $setEnvName == "ENGG" ]; then
sed -i -e "s|@@RCPT@@|"rdpreportsengg@riversand.com\",\"engqa@riversand.com"|g" mailConfig.json
sed -i -e "s|@@RCPT@@|"rdpalertsengg@riversand.com"|g" alertMailConfig.json
sed -i -e "s|@@RCPT@@|"rdpalertsengg@riversand.com"|g" warningMailConfig.json

sed -i -e "s|@@ENV_NAME@@|$envName|g" mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" alertMailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" warningMailConfig.json

elif [ $setEnvName == "CPS" ]; then
sed -i -e "s|@@RCPT@@|"rdpreportscps@riversand.com"|g" mailConfig.json
sed -i -e "s|@@RCPT@@|"rdpalertscps@riversand.com"|g" alertMailConfig.json
sed -i -e "s|@@RCPT@@|"rdpalertscps@riversand.com"|g" warningMailConfig.json

sed -i -e "s|@@ENV_NAME@@|$envName|g" mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" alertMailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName|g" warningMailConfig.json

else
sed -i -e "s|@@RCPT@@|"rdpreports@riversand.com"|g" mailConfig.json
sed -i -e "s|@@RCPT@@|"RDPAlerts@riversand.com"|g" alertMailConfig.json
sed -i -e "s|@@RCPT@@|"RDPAlerts@riversand.com"|g" warningMailConfig.json

sed -i -e "s|@@ENV_NAME@@|$envName - "PROD"|g" mailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName - "PROD"|g" alertMailConfig.json
sed -i -e "s|@@ENV_NAME@@|$envName - "PROD"|g" warningMailConfig.json
fi

#Set Up System Report Config
sed -i -e "s|@@MAIL_CONFIG@@|$basePath/AutoReports/LagReports/mailConfig.json|g" systemReportConfig.json
sed -i -e "s|@@ALERT_MAIL_CONFIG@@|$basePath/AutoReports/LagReports/alertMailConfig.json|g" systemReportConfig.json
sed -i -e "s|@@WARNING_MAIL_CONFIG@@|$basePath/AutoReports/LagReports/warningMailConfig.json|g" systemReportConfig.json

#Prepare System Report Script
sed -i -e "s|@@BASE_PATH@@|$basePath|g" systemReport.txt
sed -i -e "s|@@VERSION_NUMBER@@|$versionNumber|g" systemReport.txt
sed "s|@@REPORT_PATH@@|$basePath/AutoReports/LagReports/systemReportConfig.json|g" systemReport.txt >> systemReport.sh

chmod +x systemReport.sh