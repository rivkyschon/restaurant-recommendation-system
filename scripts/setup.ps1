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

# Create a Terraform variables file
try {
    Log-Message "Creating Terraform variables file..."

    $tfvarsContent = @"
    location = "$location"
    environment_name = "$environmentName"
    principal_id = "$principalId"
"@

    $tfvarsPath = "..\infra\terraform.tfvars"
    $tfvarsContent | Out-File -FilePath $tfvarsPath -Encoding utf8

    Log-Message "Terraform variables file created at $tfvarsPath"
}
catch {
    Log-Message "Error creating Terraform variables file: $_"
    exit 1
}


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