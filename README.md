# Terraform - SSM sessions Manager

## Overview

Simple demo that highlights how to utilize SSM Sessions Manager to connect to an EC2 (Spot) instance in a completely isolated subnet, with no access to the internet(no IGW or NAT). This is accomplished by using VPC endpoints, specifically (Privatelink) interface endpoints and an S3 Gateway endpoint(for logging).

### Logging session data
- As of April 2020, APIs for enabling Sessions Manager audit logs to S3/Cloudwatch logs are not currently available and thus this could not be automated with Terraform. This project deploys the resources needed to quickly configure encrypted audit logging to S3 as noted [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-logging-auditing.html#session-manager-logging-auditing-s3)  


## Prereqs & Dependencies

This was developed and tested with Terraform v0.12.23 and AWS-cli v2.0.4. The Lambda function is using the Python3.8 runtime and Boto3 SDK.

An AWS-cli configuration with elevated IAM permissions must be in place. The IAM access and secret keys in the AWS-cli are needed by Terraform in this example.

In order for the EC2 instance to launch successfully, you must first create an SSH key pair in the 'keys' directory named `mykey`.

```
ssh-keygen -t rsa -f ./keys/mykey -N ""
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
$ terraform destroy
```
### Connecting to the test EC2 instance
#### Via SSM CLI
Note instance ID from Terraform output. The instance might need a minute or two to initialize after Terraform completes before a connection can be made with Sessions Manager.

```
$ aws ssm start-session --target <instance_id> --region <region>
```
Initiate session with an BASH shell
```
$  aws ssm start-session --target <instance_id> --document-name AWS-StartInteractiveCommand --parameters command="bash -l" --region <region>
```
#### Via SSH(proxy)
SSHD must be running on EC2 instance and client `.ssh/config`  must be configured with:
```
host i-* mi-*

    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession —parameters 'portNumber=%p'“
```

```
$ ssh -i keys/mykey ec2-user@<instance_id>
```

#### Port Forwarding
Install Apache on the instance and start HTTPD, before this cmd.
```
$ aws ssm start-session --target <instance_id> --document-name AWS-StartPortForwardingSession  --parameters '{"portNumber":["80"], "localPortNumber":["8000"]}' --region <region>
```
