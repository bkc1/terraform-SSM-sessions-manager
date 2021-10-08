output "ec2_instance_id" { 
  value = aws_spot_instance_request.demo1.spot_instance_id
}


output "key_id" {
  value = aws_iam_access_key.demo.id
}

output "secret_key" {
  value = aws_iam_access_key.demo.ses_smtp_password_v4
}
