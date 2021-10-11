# Terraform - SSM Sessions Manager

## Overview

Simple demo that highlights how to utilize SSM Sessions Manager to connect to an EC2 (Spot) instance in a completely isolated subnet, with no access to the internet(no IGW or NAT). This uses KMS for encryption for the session and for CLoudwatch and S3 logging.  VPC (Privatelink) interface endpoints and an S3 Gateway endpoint are used for the EC2 instance to reach AWS service endpoints.

### Logging session data
- As of writing this, APIs for enabling Sessions Manager audit logs to S3/Cloudwatch logs are not currently available and thus this could not be automated with Terraform. This project deploys the resources needed to quickly configure encrypted audit logging to S3 as noted [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-logging.html)  


## Prereqs & Dependencies

This was developed and tested with Terraform `v1.0.8`, AWScli `v2.2.4` & session-manager-plugin `v.1.2.245.0`. It is strongly recommended to deploy this is a sandbox or non-production account.

* An AWS-cli configuration with elevated IAM permissions must be in place. The IAM access and secret keys in the AWS-cli are needed by Terraform in this example.

* In order for the EC2 instance to launch successfully, you must first create an SSH key pair in the 'keys' directory named `mykey`.

```
ssh-keygen -t rsa -f ./keys/mykey -N ""
```

* The Session Manager Plugin for the AWS CLI must be installed. See https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html. This plugin can also be installed using Homebrew on macOS: 
```
brew install session-manager-plugin
```

## Usage

Set the desired AWS region and change any default variables in the `variables.tf` file.

### Deploying with Terraform
```
terraform init  ## initialize Terraform
terraform plan  ## Review what Terraform will do
terraform apply ## Deploy the resources
terraform show -json |jq .values.outputs ## See redacted/sensitive Terraform outputs
```
Tear-down the resources in the stack
```
terraform destroy
```

#### Post deploy steps
As of this writing this, SSM Sessions manager does not currently have API support for enabling KMS encryption programitically, so from the SSM Sessions Manager console:
* Enable KMS encryption under `General Preferences`, selecting the `alias/demo1-dev-cwlogs` key
* Enable CW logging, selecting `ssm-sessions-mgr` for the Cloudwatch log group
* Enabld S3 logging, selecting the `ssm-sessions-mgr-logs-XXXXXX` bucket.

The KMS keys, policies, S3 buckets and CW log groups are generated for you by Terraform. 

### Connecting to the test EC2 instance
#### Via SSM CLI
Note instance ID from Terraform output. The instance might need a minute or two to initialize after Terraform completes before a connection can be made with Sessions Manager.

```
aws ssm start-session --target <instance_id> --region <region>
```
Initiate session with an BASH shell
```
aws ssm start-session --target <instance_id> --document-name AWS-StartInteractiveCommand --parameters command="bash -l" --region <region>
```
#### Via SSH(proxy)
SSHD must be running on EC2 instance and client `.ssh/config`  must be configured with:
```
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession —-parameters 'portNumber=%p'"
```

```
ssh -i keys/mykey ec2-user@<instance_id>
```

#### Port Forwarding
Connect to the instance to install Apache and start HTTPD for testing purposes:
```
aws ssm start-session --target <instance_id> --document-name AWS-StartInteractiveCommand --parameters command="bash -l" --region <region>
sudo yum install httpd
sudo service httpd start
```
Logout/terminate the SSM session and from your local host, initiate a SSH port forwarding session to the Apache server on the instance:
```
aws ssm start-session --target <instance_id> --document-name AWS-StartPortForwardingSession  --parameters '{"portNumber":["80"], "localPortNumber":["8000"]}' --region <region>

 Starting session with SessionId: user-0ad9dc99b23949f93
 Port 8000 opened for sessionId user-0ad9dc99b23949f93.
 Waiting for connections...
```
In another terminal on your local host, you should be able to connect to the Apache server test page at http://localhost:8000.

### Retricting SSM Session user access via IAM
Terraform generates an IAM user called `RestrictedUser` which only has IAM permissions to initiate an SSM session to EC2 instances. Note that the IAM policy is for example purposes and can be restricted more granularly if needed.

#### Create a AWScli profile
Copy the IAM user `key_id` and `secret_key` from the Terraform outputs and use them to create a AWScli profile.
```
aws configure --profile SSMrestricteduser
AWS Access Key ID [****************E6UT]:
AWS Secret Access Key [****************ffwz]:
Default region name [us-west-2]:
Default output format [json]:
```

#### Connect to EC2 via SSM as RestrictedUser
```
aws ssm start-session --target <instance_id> --region <region> --profile SSMRestrictedUser

Starting session with SessionId: RestrictedUser-011bf5e0b061e3c67
This session is encrypted using AWS KMS.

```
