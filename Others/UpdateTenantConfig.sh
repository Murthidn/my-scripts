#/bin/bash

#Getting input file from user
echo "Enter input file name: "
read inputFile

#Function to find and update Tenant
find_update_tenant(){

#Looping Tenant list to find and update Tenant
for tenants in $(jq '.TenantInfo | keys | .[]' $inputFile); do

    #Getting Tenant name from file
    getTenantId=$(cat $inputFile | jq '.TenantInfo['$tenants'].tenantID')

    #Getting Tenant name from user
    inputTenantName="\"$readTenantId"\"

    #Comparing Tenant and returing 0 if Tenant found
    if [ $getTenantId == $inputTenantName ]; then
	        echo $inputTenantName "Tenant Found"

          #Getting job type from user
          echo "Select job type (separated by space): PreparedData MatchStore EntityTransform"
          read jobTypeArr

          #Looping the jobs
          for jobType in $jobTypeArr; do

              if [ $jobType == "PreparedData" ]; then
                   echo "Updating the job: " $jobType "in" $inputTenantName

                   #Checking the flag and creating if it doesn't exist in PreparedData
                   isCreateInPD=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.PreparedData.created')

                   if [ $isCreateInPD == "true" ]; then
	                      echo "Flag already exists and enabled in PreparedData"

                   elif [ $isCreateInPD == "false" ]; then
	                        echo "Flag already exists and disabled in PreparedData, going ahead and enabling the Flag"
 		                      jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile                    

                   else
	                        echo "Falg doesn't exist in PreparedData, going ahead and creating the flag"
 		                      jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
                   fi


              elif [ $jobType == "MatchStore" ]; then
                     echo "Updating the job: " $jobType "in" $inputTenantName

                     #Checking the flag and creating if it doesn't exist in PreparedData
                     isCreateInMS=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.MatchStore.created')

                     if [ $isCreateInMS == "true" ]; then
	                        echo "Flag already exists and enabled in MatchStore"

                     elif [ $isCreateInMS == "false" ]; then
	                          echo "Flag already exists and disabled in MatchStore, going ahead and enabling the Flag"
 		                        jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile

                     else
	                          echo "Falg doesn't exist in MatchStore, going ahead and creating the flag"
 		                        jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
                     fi

              elif [ $jobType == "EntityTransform" ]; then
                     echo "Updating the job: " $jobType "in" $inputTenantName

                     #Checking the flag and creating if it doesn't exist in PreparedData
                     isCreateInET=$(cat $inputFile | jq '.TenantInfo['$tenants'].analytics.EntityTransform.created')

                     if [ $isCreateInET == "true" ]; then
	                        echo "Flag already exists and enabled in EntityTransform"

                     elif [ $isCreateInET == "false" ]; then
	                          echo "Flag already exists and disabled in EntityTransform, going ahead and enabling the Flag"
 		                        jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile

                     else
	                          echo "Falg doesn't exist in EntityTransform, going ahead and creating the flag"
 		                        jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' $inputFile > tmp.json && mv --force tmp.json $inputFile
                     fi

            else
              echo $jobType "job doesn't exist" in $inputTenantName

            fi

          done
          return 0
    fi
    
done
    #Returning 1 if Tenant doesn't exist
    return 1
}

#Main function
update_tenant_config(){
  
#Getting Tenant name from User
echo "Enter Tenant Name: "
read readTenantId

#Calling function to change Tenant
find_update_tenant readTenantId
FIND_TENANT_RETURN_CODE=$?

#Printing if given Tenant doesn't exist
if [ $FIND_TENANT_RETURN_CODE -ne "0" ]; then
	   echo $readTenantId "Tenant doesn't exist"
fi


# Asking user to continue or not to update other Tenants
echo "Do you want to update another Tenant (y/n) ?"
read answer

if [ $answer = y ]
  then update_tenant_config

elif [ $answer = n ]
  then echo "Exiting Program"
  exit 0

fi
}

#Main Program Starting
update_tenant_config