# Terraform - SSM Sessions Manager

## Overview

Simple demo that highlights how to utilize SSM Sessions Manager to connect to an EC2 (Spot) instance in a completely isolated subnet, with no access to the internet(no IGW or NAT). This uses KMS for encryption for the session and for CLoudwatch and S3 logging.  This is accomplished by using VPC endpoints, specifically (Privatelink) interface endpoints and an S3 Gateway endpoint(for logging).

### Logging session data
- As of writing this, APIs for enabling Sessions Manager audit logs to S3/Cloudwatch logs are not currently available and thus this could not be automated with Terraform. This project deploys the resources needed to quickly configure encrypted audit logging to S3 as noted [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-logging.html)  


## Prereqs & Dependencies

This was developed and tested with Terraform v0.14.4, AWScli v2.2.4 & session-manager-plugin v.1.2.245.0

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
terraform init  ## initialize Teraform
terraform plan  ## Review what terraform will do
terraform apply ## Deploy the resources
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
Install Apache on the instance and start HTTPD, before this cmd.
```
aws ssm start-session --target <instance_id> --document-name AWS-StartPortForwardingSession  --parameters '{"portNumber":["80"], "localPortNumber":["8000"]}' --region <region>
```
