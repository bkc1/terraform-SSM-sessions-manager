{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OnlyAllowSSHviaSSM",
            "Effect": "Allow",
            "Action": "ssm:StartSession",
            "Resource": [
                "arn:aws:ssm:*::document/AWS-StartSSHSession",
                "arn:aws:ec2:*:${account_id}:instance/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "${key_arn}"
        },
        {
            "Effect": "Allow",
            "Action": "kms:GenerateDataKey",
            "Resource": "*"
        }
    ]
}
