#!/bin/bash

ID=0
NO_EXEC=0

while getopts "i:N" opt; do
  case $opt in
    i)
      ID=$OPTARG
      ;;
    N)
      echo "Mode - No exec, show command only"
      NO_EXEC=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


GET_INSTANCE_ID=(/usr/local/bin/jq "-r" ".\"mak3r-k8s\".\"instances\"[$ID]" "instance-ids.json")
INSTANCE_ID=`${GET_INSTANCE_ID[@]}`
GET_PUBLIC_DNS=(/usr/local/bin/aws "ec2" "describe-instances" "--instance-ids" "$INSTANCE_ID" "|" "/usr/local/bin/jq" ".\"Reservations\"[0].\"Instances\"[0].\"PublicDnsName\"" "--")

PUBLIC_DNS=$(eval ${GET_PUBLIC_DNS[@]})

SSH_CMD=(/usr/bin/ssh "-i" "aws-mak3r.pem" "ubuntu@$PUBLIC_DNS")
echo ${SSH_CMD[@]}

# Only execute the command if the no exec flag has not been raised.
if [ $NO_EXEC -eq 0 ]
then
  echo "Connecting to $PUBLIC_DNS"
  eval ${SSH_CMD[@]}  
fi
