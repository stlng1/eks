# eks
building eks with terraform


Artifactory
1. Associate an IAM role to a service account using the values.yaml of Artifactory Helm Chart : 
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>
⧉
  
2. Configure the binarystore.xml using the values.yaml of Artifactory Helm Chart:
artifactory:
  persistence:
    awsS3V3:
      region: AWS_REGION
      bucketName: AWS_BUCKET_NAME
      useInstanceCredentials: true
⧉
  
3. Restart Artifactory