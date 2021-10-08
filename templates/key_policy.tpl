{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [ 
    {
      "Sid" : "EnableIAMUserPermissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": { 
          "Service": "logs.${region}.amazonaws.com" 
      },
      "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
      ],
      "Resource": "*",
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "ssm.amazonaws.com"
      },
      "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
      ],
      "Resource": "*"            
    }
  ]
}
