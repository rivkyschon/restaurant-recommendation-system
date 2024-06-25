# Define the log file path
$logFilePath = "setup-infra.log"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
    $logMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Start logging
Log-Message "Starting Azure infrastructure setup script"

# Login to Azure
try {
    Log-Message "Logging in to Azure..."
    az login | Out-Null
    Log-Message "Successfully logged in to Azure"
}
catch {
    Log-Message "Error logging in to Azure: $_"
    exit 1
}

# Use the retrieved principal ID
$principalId = "761882b5-4071-4968-9765-48b02a3e6ecb"
Log-Message "Principal ID: $principalId"

# Request necessary input from the user
$location = Read-Host "Enter the Azure location (e.g., eastus2)"
$environmentName = Read-Host "Enter the environment name"

# Define any additional service principal or managed identity IDs (if needed)
# These should be predefined and added here if applicable
$additionalAccessPolicyObjectIds = @()
# Example: Add service principal or managed identity IDs here
# $additionalAccessPolicyObjectIds += "your-service-principal-id"
# $additionalAccessPolicyObjectIds += "your-managed-identity-id"

# Combine your user principal ID with any additional IDs
$accessPolicyObjectIds = @($principalId) + $additionalAccessPolicyObjectIds

Log-Message "User inputs - Location: $location, Environment Name: $environmentName, Access Policy Object IDs: $accessPolicyObjectIds"

# Retrieve the current subscription ID
try {
    Log-Message "Retrieving current subscription ID..."
    $subscriptionId = az account show --query "id" -o tsv
    Log-Message "Current subscription ID: $subscriptionId"
}
catch {
    Log-Message "Error retrieving subscription ID: $_"
    exit 1
}

# Generate a resource token
try {
    Log-Message "Generating resource token..."
    $resourceToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$environmentName$location$subscriptionId"))
    $resourceToken = $resourceToken.Substring(0, 13).ToLower().Replace("[^A-Za-z0-9_]", "")
    Log-Message "Resource token: $resourceToken"
}
catch {
    Log-Message "Error generating resource token: $_"
    exit 1
}

# Generate a unique Cosmos connection string key (for demo purposes, use a GUID)
$cosmosConnectionStringKey = "AZURE-COSMOS-CONNECTION-STRING"
Log-Message "Cosmos connection string key: $cosmosConnectionStringKey"

# Create a Terraform variables file
try {
    Log-Message "Creating Terraform variables file..."

    # Create the content for the .tfvars file
    $tfvarsContent = @"
    location = "$location"
    environment_name = "$environmentName"
    principal_id = "$principalId"
"@

    # Save the variables to a .tfvars file in the infra directory
    $tfvarsPath = "..\infra\terraform.tfvars"
    $tfvarsContent | Out-File -FilePath $tfvarsPath -Encoding utf8

    Log-Message "Terraform variables file created at $tfvarsPath"
}
catch {
    Log-Message "Error creating Terraform variables file: $_"
    exit 1
}

# Change directory to the infra folder before running Terraform commands
Set-Location -Path "..\infra"

# Run Terraform initialization and apply
try {
    Log-Message "Initializing Terraform..."
    terraform init | Out-File -FilePath "..\scripts\$logFilePath" -Append -Encoding utf8
    Log-Message "Terraform initialized successfully"
}
catch {
    Log-Message "Error initializing Terraform: $_"
    exit 1
}

try {
    Log-Message "Applying Terraform configuration..."
    terraform apply -var-file=$tfvarsPath -auto-approve | Out-File -FilePath "..\scripts\$logFilePath" -Append -Encoding utf8
    Log-Message "Terraform configuration applied successfully"
}
catch {
    Log-Message "Error applying Terraform configuration: $_"
    exit 1
}

Log-Message "Azure infrastructure setup script completed"