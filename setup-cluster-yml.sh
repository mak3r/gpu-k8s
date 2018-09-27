#!/bin/bash

echo $1
echo "address:"
aws ec2 describe-instances --instance-ids $(jq -r '."mak3r-k8s"."instances"[$1]' instance-ids.json) | jq -r  '."Reservations"[0]."Instances"[0]."PrivateIpAddress"' --
echo "internal_address:"
aws ec2 describe-instances --instance-ids $(jq -r '."mak3r-k8s"."instances"[$1]' instance-ids.json) | jq -r  '."Reservations"[0]."Instances"[0]."PublicIpAddress"' --

