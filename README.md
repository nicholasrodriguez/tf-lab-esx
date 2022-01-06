# terraform-lab
Lab for Terraform Associate Exam

[https://learn.hashicorp.com/collections/terraform/certification-associate-tutorials]

# Notes

## Migrate State From TFC back to Local

```
mv backend.tf backend.tf.old
terraform init -migrate-state
```
## Migrate State From Local back to TFC
Make sure backend.tf is available
```
rm terraform.tfstate
terraform init -migrate-state
terraform plan
```

## Execution Mode
Set Execution Mode on workspace to Local for internal runs i.e. for home lab hosts not on the internet. This just stores the state remotely.
