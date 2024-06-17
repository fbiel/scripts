#!/bin/bash

# Check if the AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed.' >&2
  exit 1
fi

# check if argument for profile is provided
# if not, use the default profile
if [ -z "$3" ]; then
  profile="default"
else
  profile="$3"
fi


# Get the executing user's IP
user_ip=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')

# Get the list of security groups
security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupName' --profile "$profile" --output text)

# Print the list of security groups
echo "Select the security group:"
select security_group in $security_groups; do
  if [ -n "$security_group" ]; then
    break
  else
    echo "Invalid selection"
  fi
done

# Assign default values for protocol and port if not provided
protocol=${1:-"tcp"}
port=${2:-"22"}

# Add the inbound rule for the specified protocol and port
response=$(aws ec2 authorize-security-group-ingress --group-name "$security_group" --profile "$profile" --protocol "$protocol" --port "$port" --cidr "$user_ip/32")

echo "Successfully added $protocol access on port $port to the security group $security_group with CIDR range $user_ip/32"
echo $response
# Get the ID of the newly created security rule
rule_id=$(echo $response | jq -r '.SecurityGroupRules[0].SecurityGroupRuleId')

# Print the AWS CLI command that can be used to delete the security rule
echo "***************************************************************************"
echo "*** Don't forget to delete the security rule when you are done with it. ***"
echo "*** Use the following command:                                          ***"
echo "aws ec2 revoke-security-group-ingress --group-name $security_group --security-group-rule-id $rule_id --profile ""$profile"""
echo "***                                                                     ***"
echo "***************************************************************************"