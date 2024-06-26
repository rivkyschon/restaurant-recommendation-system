# deploy.ps1

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$command
    )
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

# Check if Docker is installed
if (-not (Command-Exists docker)) {
    Write-Error "Docker is not installed. Please install Docker and try again."
    exit 1
}

# Navigate to the backend directory
Set-Location -Path "..\api"

# Build Docker image
Write-Output "Building Docker image..."
docker build -t restaurant-recommendation-system:latest .
if ($?) {
    Write-Output "Docker image built successfully."
} else {
    Write-Error "Failed to build Docker image."
    exit 1
}

# Stop and remove existing container
Write-Output "Stopping existing Docker container..."
docker stop restaurant-recommendation-system
docker rm restaurant-recommendation-system

# Run new Docker container
Write-Output "Running new Docker container..."
docker run -d -p 5000:5000 --name restaurant-recommendation-system restaurant-recommendation-system:latest
if ($?) {
    Write-Output "New Docker container is running successfully."
} else {
    Write-Error "Failed to run new Docker container."
    exit 1
}

Write-Output "Deployment completed successfully."
