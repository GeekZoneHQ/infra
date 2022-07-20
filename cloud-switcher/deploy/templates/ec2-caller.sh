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

i=0
result=0

if [ $(sudo curl --write-out %{http_code} --silent --output /dev/null "https://test.geek.zone" ) -eq 200 ]
then
  echo " The website is healthy"
else  
  while [ "$i" -le 5 ]
  do
  i=$(( i + 1 ))
  echo $i
  date
    
  if [ $(sudo curl --write-out %{http_code} --silent --output /dev/null "https://test.geek.zone" ) -eq 200 ]
  then
     exit 0
  elif [ "$i" -gt 5 ]
  then
      echo $i
      date
      echo "success"
      sudo curl -u ${CIRCLECI_TOKEN}: -X POST --header "Content-Type: application/json" -d '{
        "branch": "br_cloud_switcher",
        "parameters": {     
        "deploy_infra_aws": false,
        "deploy_infra_azure": true,     
        "main_infra_build": false
        }
      }' https://circleci.com/api/v2/project/gh/GeekZoneHQ/infra/pipeline      
      echo "success and reset"
      date
      mv /home/ubuntu/ec2-caller.sh /home/ubuntu/ec2-caller-1.sh
      date
  fi
  done
fi

