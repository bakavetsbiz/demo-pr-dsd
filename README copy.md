### To deploy infrastructure do the folowing:

Create IAM User in AWS with Admin permissions and create Access keys.

Open terminal:

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

cd terraform

terraform init
```

Fill the file terraform/helm.tf with the appropriate values.

```
terraform plan

terraform apply
```