#!/bin/bash

NAME="abc"
VERBOSE=0

while getopts "n:v" opt; do
  case $opt in
    n)
      #echo "handling name -$OPTARG"
      NAME=$OPTARG
      ;;
    v) 
      VERBOSE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ "$VERBOSE" -ne 0 ]; then echo $NAME; fi

#ids=$(aws ec2 describe-tags --filters "Name=tag:Name,Values=$NAME" "Name=resource-type,Values=instance" | jq ."Tags"[]."ResourceId" | aws ec2 describe-instances --filters "Name=instance-state-code,Values=16" --instance-ids -- | jq '."Reservations"[]."Instances"[]."InstanceId"')
#set -x
FIND_BY_NAME=(/usr/local/bin/aws "ec2" "describe-tags" "--filters" "Name=tag:Name,Values=$NAME" "Name=resource-type,Values=instance")
NAMED_RESOURCES=`${FIND_BY_NAME[@]}`
if [ "$VERBOSE" -ne 0 ]; then echo Named Resources: $NAMED_RESOURCES; fi
IS_EMPTY=(/usr/local/bin/jq  ".\"Tags\" | if select(length>0) then . else empty end" )
if [ "$VERBOSE" -ne 0 ]; then echo is empty: "${IS_EMPTY[@]}"; fi

###############
# FIXME
# I'm attempting to setup a test to see if the list of resources is empty
# before continuing. If the list is empty, we should stop here
# If we don't stop here then the next query may list instances which we don't
# Want to be including because the query matched nothing and thus we end up
# with a reference to all available instances (blech)
###############
NAME_FOUND="hello"
#$(eval echo "$NAMED_RESOURCES" | "${IS_EMPTY[@]}")

if [ "$VERBOSE" -ne 0 ]; then echo name found: "$NAME_FOUND"; fi

if [ ! -z "$NAME_FOUND" ]; then
    PULL_RESOURCE_IDS=(/usr/local/bin/jq "-r" ".\"Tags\"[].\"ResourceId\"")

    BY_RESOURCE_ID=`${FIND_BY_NAME[@]} | ${PULL_RESOURCE_IDS[@]} `

    if [ "$VERBOSE" -ne 0 ]; then echo BYID $BY_RESOURCE_ID BYID; fi
    #instance-state-code=16 is RUNNING
    DESCRIBE_RUNNING=(/usr/local/bin/aws "ec2" "describe-instances" "--filters" "Name=instance-state-code,Values=16" "--instance-ids" "$BY_RESOURCE_ID")
    if [ "$VERBOSE" -ne 0 ]; then echo RUNNING ${DESCRIBE_RUNNING[@]} RUNNING ; fi
    ONLY_RESOURCE_IDS=(/usr/local/bin/jq '."Reservations"[]."Instances"[]."InstanceId"')

    IDS=`${DESCRIBE_RUNNING[@]} | ${ONLY_RESOURCE_IDS[@]} `
    if [ "$VERBOSE" -ne 0 ]; then echo $IDS; fi
fi

printf '{ \"'"mak3r-k8s"'\": { "instances": ['
if [ ! -z "$NAME_FOUND" ]; then
    j=0
    for i in $IDS; do
    if [ $j -ne 0 ]; then
        printf ,
    fi
    printf $i;
    let j=j+1
    done
fi
echo ']}}'
