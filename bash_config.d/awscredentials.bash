#!/bin/bash

CREDS=$HOME/.ssh/amazon_tm_credentials.csv

export AWS_USER_NAME=$(tail -n1 $CREDS | cut -d',' -f1)
export AWS_ACCESS_KEY=$(tail -n1 $CREDS | cut -d',' -f2)
export AWS_SECRET_KEY=$(tail -n1 $CREDS | cut -d',' -f3)

export EC2_HOME="${HOME}/src/ec2-api-tools-1.6.13.0"
export EC2_URL="https://ec2.eu-west-1.amazonaws.com"

export PATH=$PATH:$EC2_HOME/bin
