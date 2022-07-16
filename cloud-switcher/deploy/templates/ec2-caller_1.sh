#!/bin/sh

: '
check the health of the https://geek.zone
try for 10 times with a interval of 10 seconds
at the end of the 10th time, trigger the API to spin up the AZURE Infra in the CircleCI
0-aws  
1-azure
Need to implement the trigger mechanism once the AWS is spic and span 
'
export CIRCLECI_TOKEN=$(echo ${CIRCLECI_TOKEN})

httpUrl="https://test.geek.zone"
rep=$(sudo curl -s -o /dev/null -w "%{http_code}"  $httpUrl)

i=0
result=0

if [ "$rep" -eq 200 ]
then
  echo " The website is healthy"
  exit 0
else  
  while [ $i -le 5 ]
  do
  i=$(( i+1 ))	 # increment $i
  date
  rep=$(sudo curl -s -o /dev/null -w "%{http_code}"  $httpUrl)

  if [ "$rep" -eq 200 ]
  then
     echo " The website is healthy"
     exit 0
  else 
    if [ $i -ge 5 ]
    then
    	echo "Trigger the restart $i times."
      sudo curl -u ${CIRCLECI_TOKEN}: -X POST --header "Content-Type: application/json" -d '{
          "branch": "${CIRCLE_BRANCH}",
          "parameters": {     
          "deploy_infra_aws": false,
          "deploy_infra_azure": true,     
          "main_infra_build": false
          }
        }' https://circleci.com/api/v2/project/gh/GeekZoneHQ/infra/pipeline
      date
  	  sleep 10
  	  date
  	  exit 0
    fi
  fi
  done
fi

