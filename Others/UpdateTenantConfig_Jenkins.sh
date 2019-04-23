#/bin/bash


#Function to find and update Tenant
find_update_tenant(){

#Looping Tenant list to find and update Tenant
for tenants in $(jq '.TenantInfo | keys | .[]' $1); do

    #Getting Tenant name from file
    getTenantId=$(cat $1 | jq '.TenantInfo['$tenants'].tenantID')

    #Getting Tenant name from user
    inputTenantName="\"$2"\"

    #Comparing Tenant and returing 0 if Tenant found
    if [ $getTenantId == $inputTenantName ]; then
	        echo -e "\nINFO: $inputTenantName Tenant Found\n"
        
         #Preparing jobs array
         jobtypes=$3
         jobs=(${jobtypes//,/ })
         for j in "${!jobs[@]}"
         do
           jobTypeArr+="${jobs[j]} "
         done

          #Looping the jobs
          for jobType in $jobTypeArr; do

              if [ $jobType == "PreparedData" ]; then
                   
                   echo -e "-----------------------------Start : $jobType -----------------------------\n"

                   #Checking the flag and creating if it doesn't exist in PreparedData
                   isCreateInPD=$(cat $1 | jq '.TenantInfo['$tenants'].analytics.PreparedData.created')

                   if [ $isCreateInPD == "true" ]; then
	                      echo -e "Flag already exists and enabled in PreparedData\n"

                   elif [ $isCreateInPD == "false" ]; then
	                        echo -e "Flag already exists and disabled in PreparedData, going ahead and enabling the Flag\n"
 		                      jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' $1 > tmp.json && mv --force tmp.json $1                    

                   else
	                        echo -e "Falg doesn't exist in PreparedData, going ahead and creating the flag\n"
 		                      jq '.TenantInfo['$tenants'].analytics.PreparedData += {"created": true}' $1 > tmp.json && mv --force tmp.json $1
                   fi

                   echo -e "-----------------------------End : $jobType -----------------------------\n\n"


              elif [ $jobType == "MatchStore" ]; then

                   echo -e "-----------------------------Start : $jobType -----------------------------\n"

                     #Checking the flag and creating if it doesn't exist in PreparedData
                     isCreateInMS=$(cat $1 | jq '.TenantInfo['$tenants'].analytics.MatchStore.created')

                     if [ $isCreateInMS == "true" ]; then
	                        echo -e "Flag already exists and enabled in MatchStore\n"

                     elif [ $isCreateInMS == "false" ]; then
	                          echo -e "Flag already exists and disabled in MatchStore, going ahead and enabling the Flag\n"
 		                        jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' $1 > tmp.json && mv --force tmp.json $1

                     else
	                          echo -e "Falg doesn't exist in MatchStore, going ahead and creating the flag\n"
 		                        jq '.TenantInfo['$tenants'].analytics.MatchStore += {"created": true}' $1 > tmp.json && mv --force tmp.json $1
                     fi

                   echo -e "-----------------------------End : $jobType -----------------------------\n\n"

              elif [ $jobType == "EntityTransform" ]; then

                   echo -e "-----------------------------Start : $jobType -----------------------------\n"

                     #Checking the flag and creating if it doesn't exist in PreparedData
                     isCreateInET=$(cat $1 | jq '.TenantInfo['$tenants'].analytics.EntityTransform.created')

                     if [ $isCreateInET == "true" ]; then
	                        echo -e "Flag already exists and enabled in EntityTransform\n"

                     elif [ $isCreateInET == "false" ]; then
	                          echo -e "Flag already exists and disabled in EntityTransform, going ahead and enabling the Flag\n"
 		                        jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' $1 > tmp.json && mv --force tmp.json $1

                     else
	                          echo -e "Falg doesn't exist in EntityTransform, going ahead and creating the flag\n"
 		                        jq '.TenantInfo['$tenants'].analytics.EntityTransform += {"created": true}' $1 > tmp.json && mv --force tmp.json $1
                     fi

                   echo -e "-----------------------------End : $jobType -----------------------------\n\n"

            else
              echo -e "ERROR: $jobType job doesn't exist in storage account file, please verify.\n"

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

inputFileName=$1
readTenant=$2

#Calling function to change given Tenant
find_update_tenant $inputFileName $readTenant $3

#Printing if given Tenant doesn't exist
FIND_TENANT_RETURN_CODE=$?

if [ $FIND_TENANT_RETURN_CODE -ne "0" ]; then
        echo -e "\nERROR: $2 Tenant doesn't exist, verify the storage account file.\n"
fi

}

#Main Program Starting
update_tenant_config $1 $2 $3