#!/bin/bash

ssh-keygen -t rsa -f connect-test

aws ec2-instance-connect send-ssh-public-key \
  --region us-east-1 \
  --instance-id i-0f3ecb6e4c1f9ca49 \
  --availability-zone us-east-1a \
  --instance-os-user ec2-user \
  --ssh-public-key file://connect-test.pub

ssh -i connect-test ec2-user@54.227.180.254

rm connect-test connect-test.pub
