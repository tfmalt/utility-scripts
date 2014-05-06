#!/bin/bash

DOMAIN=$(hostname -f | sed -n -e 's/^.*\.\(.*\..*\)$/\1/p')
CREDS=""
case $DOMAIN in
    fronter.*)
        CREDS=$HOME/.ssh/aws_fronter_credentials.json
        ;;
    malt.no)
        CREDS=$HOME/.ssh/aws_tm_credentials.json
        ;;
esac

echo $DOMAIN: $CREDS

if [ $CREDS != "" ]; then
    AWS_ACCESS_KEY=$(cat $CREDS | sed -n -e 's/^.*AWS_ACCESS_KEY.*: *"\(.*\)".*$/\1/p')
    AWS_SECRET_KEY=$(cat $CREDS | sed -n -e 's/^.*AWS_SECRET_KEY.*: *"\(.*\)".*$/\1/p')
    AWS_USER_NAME=$(cat $CREDS | sed -n -e 's/^.*AWS_USER_NAME.*: *"\(.*\)".*$/\1/p')

    export AWS_USER_NAME AWS_SECRET_KEY AWS_ACCESS_KEY
    export EC2_HOME="${HOME}/src/ec2-api-tools-1.6.13.0"
    export EC2_URL="https://ec2.eu-west-1.amazonaws.com"

    export PATH=$PATH:$EC2_HOME/bin
fi


