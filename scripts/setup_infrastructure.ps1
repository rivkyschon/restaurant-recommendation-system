# Log in to Azure account
Write-Host "Logging into Azure account..."
az login

# Navigate to the Terraform directory
$terraformDir = "..\infra"
Set-Location -Path $terraformDir

# Initialize Terraform
Write-Host "Initializing Terraform..."
terraform init

# Validate Terraform configuration
Write-Host "Validating Terraform configuration..."
terraform validate

# Plan Terraform deployment
$planFile = "terraform.tfplan"
Write-Host "Planning Terraform deployment and saving the plan to $planFile..."
terraform plan -out=$planFile

# Prompt for user consent before applying the plan
$applyPlan = Read-Host "Do you want to apply the Terraform plan? (yes/no)"
if ($applyPlan -eq "yes") {
    # Apply Terraform plan
    Write-Host "Applying Terraform plan..."
    terraform apply -input=false $planFile

    Write-Host "Terraform deployment completed."
} else {
    Write-Host "Terraform deployment aborted by user."
}
