
#automate connecting to aws instances instance-id is constant but public ip can change

## Tools needed
aws-cli
jq

## standard ssh command provided by aws console UI
`ssh -i "aws-mak3r.pem" ubuntu@ec2-34-201-102-151.compute-1.amazonaws.com`

## example instance id
i-04855eeb4c61452b0

## example of describing aws instance given a known ID
`aws ec2 describe-instances --instance-ids i-04855eeb4c61452b0 > instance-example.json`

## create a local file with a list of instance ids
`instance-ids.json`
```{ "project-name": {"instances": ["id-1", "id-2", "id-3"]}}```

## jq query to get the first instance id. my project-name is mak3r-k8s.
`jq -r '."mak3r-k8s"."instances"[0]' instance-ids.json`

## combine the description of an aws instance with the query to get an instance id from my file
`aws ec2 describe-instances --instance-ids $(jq -r '."mak3r-k8s"."instances"[0]' instance-ids.json)`

## Pull the public dns name from the instance
`jq '."Reservations"[0]."Instances"[0]."PublicDnsName"' instance-example.json`

## Combine commands to get publc dns name given instance id
`aws ec2 describe-instances --instance-ids $(jq -r '."mak3r-k8s"."instances"[0]' instance-ids.json) | jq '."Reservations"[0]."Instances"[0]."PublicDnsName"' --`

## Create a shell script which take a numeric argument to connect to the instances
`ssh-connect.sh`
```
#!/bin/bash

ID=0

while getopts "i:" opt; do
  case $opt in
    i)
      echo "-a was triggered! $ID" >&2
      ID=$OPTARG
      break
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
echo "Connecting to $PUBLIC_DNS"

SSH_CMD=(/usr/bin/ssh "-i" "aws-mak3r.pem" "ubuntu@$PUBLIC_DNS")
echo ${SSH_CMD[@]}
eval ${SSH_CMD[@]}
```