#!/bin/bash
echo "=== AWS Resource Verification ==="
echo "Date: $(date)"
echo ""

echo "=== 1. S3 Bucket ==="
aws s3 ls | grep lesson5

echo ""
echo "=== 2. DynamoDB Table ==="
aws dynamodb list-tables --output table

echo ""
echo "=== 3. VPC ==="
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*lesson-5*" \
  --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output table

echo ""
echo "=== 4. Subnets ==="
aws ec2 describe-subnets --filters "Name=tag:Name,Values=*lesson-5*" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' \
  --output table

echo ""
echo "=== 5. NAT Gateway (ПЛАТНИЙ!) ==="
aws ec2 describe-nat-gateways --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,State,CreateTime]' \
  --output table

echo ""
echo "=== 6. ECR Repository ==="
aws ecr describe-repositories --query 'repositories[*].[repositoryName,repositoryUri]' \
  --output table

echo ""
echo "=== Verification Complete ==="
